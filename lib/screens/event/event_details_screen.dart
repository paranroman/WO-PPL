import 'package:eventure/api/database_service.dart';
import 'package:eventure/models/user_model.dart';
import 'package:eventure/providers/auth_provider.dart';
import 'package:eventure/widgets/comment_section.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eventure/widgets/app_header.dart';
import 'package:eventure/widgets/app_scaffold.dart';
import '../../models/event_model.dart';
import '../../navigation/app_router.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final Color primaryColor = const Color(0xFFD64A53);
  bool _isSubmittingRsvp = false;

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return AppScaffold(
      body: SafeArea(
        child: FutureBuilder<UserModel?>(
          future: authProvider.getUserData(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentUser = userSnap.data;
            final userId = currentUser?.uid ?? '';
            if (userId.isEmpty) {
              return const Center(
                child: Text(
                  'Silakan login terlebih dahulu',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              );
            }

            return StreamBuilder<DatabaseEvent>(
              stream: db.getEventStream(widget.eventId),
              builder: (context, eventSnap) {
                if (eventSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final raw = eventSnap.data?.snapshot.value;
                if (raw == null || raw is! Map) {
                  return const Center(
                    child: Text(
                      'Event tidak ditemukan',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  );
                }

                final map = Map<String, dynamic>.from(raw);
                final event = EventModel.fromJson(map);
                final price = (map['price'] as String?) ?? 'Gratis';

                final tags = event.tags
                    .split(',')
                    .map((t) => t.trim())
                    .where((t) => t.isNotEmpty)
                    .toList();

                final isOwner = event.organizerId == userId;

                return StreamBuilder<DatabaseEvent>(
                  stream: db.getUserRsvpStream(widget.eventId, userId),
                  builder: (context, rsvpSnap) {
                    final rsvpRaw = rsvpSnap.data?.snapshot.value;

                    final bool isRegistered =
                        rsvpSnap.hasData && rsvpSnap.data!.snapshot.exists && rsvpRaw != null;

                    bool isAttended = false;
                    if (rsvpRaw is Map) {
                      final rsvpMap = Map<dynamic, dynamic>.from(rsvpRaw);
                      isAttended = (rsvpMap['attended'] == true);
                    }

                    final String buttonText = isOwner
                        ? "Dashboard"
                        : isAttended
                        ? "Sudah Hadir"
                        : isRegistered
                        ? "Sudah Terdaftar"
                        : "RSVP";

                    final bool canPress = !_isSubmittingRsvp && (isOwner || !isRegistered);

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppHeader(),
                          _buildBannerSection(context, event),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  event.organizerName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (tags.isNotEmpty)
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: tags
                                        .map(
                                          (tag) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFE5E5),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              tag,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFFD64F5C),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                const SizedBox(height: 20),
                                _buildSectionTitle("Deskripsi Event"),
                                _buildInfoContainer(
                                  height: 120,
                                  child: SingleChildScrollView(
                                    child: Text(
                                      event.description,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: primaryColor),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              price,
                                              style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              event.isOnline ? 'Mode: Online' : 'Mode: Offline',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: primaryColor,
                                                  foregroundColor: Colors.white,
                                                  disabledBackgroundColor: primaryColor.withAlpha(
                                                    45,
                                                  ),
                                                  disabledForegroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                onPressed: canPress
                                                    ? () async {
                                                        if (isOwner) {
                                                          context.go(
                                                            AppRoutes.eventDashboard.replaceFirst(
                                                              ':eventId',
                                                              widget.eventId,
                                                            ),
                                                          );
                                                          return;
                                                        }

                                                        // Store references before async operation
                                                        final scaffoldMessenger =
                                                            ScaffoldMessenger.of(context);

                                                        setState(() => _isSubmittingRsvp = true);

                                                        try {
                                                          await db.registerForEvent(
                                                            widget.eventId,
                                                            userId,
                                                          );

                                                          if (mounted) {
                                                            scaffoldMessenger.showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  'Berhasil RSVP',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.w500,
                                                                  ),
                                                                ),
                                                                backgroundColor: Colors.green,
                                                              ),
                                                            );
                                                          }
                                                        } catch (_) {
                                                          if (mounted) {
                                                            scaffoldMessenger.showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  'Gagal RSVP, coba lagi',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.w500,
                                                                  ),
                                                                ),
                                                                backgroundColor: Colors.red,
                                                              ),
                                                            );
                                                          }
                                                        } finally {
                                                          if (mounted) {
                                                            setState(
                                                              () => _isSubmittingRsvp = false,
                                                            );
                                                          }
                                                        }
                                                      }
                                                    : null,
                                                child: _isSubmittingRsvp
                                                    ? const SizedBox(
                                                        height: 18,
                                                        width: 18,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    : FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          buttonText,
                                                          maxLines: 1,
                                                          softWrap: false,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (!event.isOnline)
                                            InkWell(
                                              borderRadius: BorderRadius.circular(12),
                                              onTap: () => _openLocationInMaps(context, event),
                                              child: _buildInfoContainer(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Alamat:",
                                                      style: TextStyle(fontWeight: FontWeight.w600),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      cleanAddress(event.locationAddress),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    const Align(
                                                      alignment: Alignment.centerRight,
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.map,
                                                            size: 14,
                                                            color: Colors.red,
                                                          ),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            "Lihat di Google Maps",
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color: Colors.red,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          else
                                            _buildInfoContainer(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Acara Online",
                                                    style: TextStyle(fontWeight: FontWeight.w600),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    event.onlineLink ?? '-',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildSectionTitle("Waktu diselenggarakan"),
                                _buildInfoContainer(
                                  child: Text(
                                    _buildDateTimeLabel(event),
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildSectionTitle("Komentar"),
                                CommentSection(
                                  eventId: widget.eventId,
                                  currentUserId: userId,
                                  currentUserName: currentUser?.name ?? 'Anonim',
                                  currentUserPhotoUrl: currentUser?.profilePicture,
                                  isOrganizer: isOwner,
                                  organizerId: event.organizerId,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBannerSection(BuildContext context, EventModel event) {
    final bannerUrl = event.bannerUrl;
    final avatarUrl = event.photoUrl;
    final timeLabel = "${event.startTime} - ${event.endTime} WIB";

    return SizedBox(
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: bannerUrl != null && bannerUrl.isNotEmpty
                    ? NetworkImage(bannerUrl)
                    : const NetworkImage(
                        'https://via.placeholder.com/800x400/E55B5B/FFFFFF?text=Banner+Event',
                      ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(height: 180, color: const Color(0xFF2C1F38).withAlpha(80)),
          Positioned(
            top: 20,
            right: 20,
            child: SizedBox(
              width: 220,
              child: Text(
                event.eventType.toUpperCase(),
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: InkWell(
              onTap: () => context.go(AppRoutes.home),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
            ),
          ),
          Positioned(
            top: 185,
            right: 20,
            child: Text(
              event.isOnline ? "Online\n$timeLabel" : "Offline\n$timeLabel",
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 30,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : const NetworkImage(
                        'https://via.placeholder.com/200x200/E55B5B/FFFFFF?text=Foto',
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInfoContainer({required Widget child, double? height}) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor),
        borderRadius: BorderRadius.circular(12),
        color: Colors.pink.withAlpha(2),
      ),
      child: child,
    );
  }

  String _buildDateTimeLabel(EventModel event) {
    String dateLabel = event.eventDay;
    try {
      final parsed = DateTime.parse(event.eventDay);
      dateLabel = DateFormat('EEEE, dd MMMM yyyy').format(parsed);
    } catch (_) {}
    return "$dateLabel\n${event.startTime} - ${event.endTime} WIB";
  }

  String cleanAddress(String raw) {
    return raw.replaceAll(",,", ",").replaceAll(RegExp(r',$'), "").trim();
  }

  Future<void> _openLocationInMaps(BuildContext context, EventModel event) async {
    if (event.isOnline) return;

    final lat = event.locationLat;
    final lng = event.locationLng;
    final address = cleanAddress(event.locationAddress);

    Uri uri;
    if (lat != null && lng != null) {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
      );
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak dapat membuka Google Maps',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      );
    }
  }
}
