import 'package:eventure/api/database_service.dart';
import 'package:eventure/providers/auth_provider.dart';
import 'package:eventure/widgets/app_header.dart';
import 'package:eventure/widgets/app_scaffold.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../navigation/app_router.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/legend_row.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/pie_chart.dart';

class EventDashboardScreen extends StatelessWidget {
  final String eventId;

  const EventDashboardScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    const primaryColor = Color(0xFFD64A53);

    return AppScaffold(
      body: SafeArea(
        child: FutureBuilder<String?>(
          future: Provider.of<AuthProvider>(
            context,
            listen: false,
          ).currentUser(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final userId = (userSnap.data ?? '').trim();
            if (userId.isEmpty) {
              return const Center(
                child: Text(
                  'Silakan login terlebih dahulu',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            return StreamBuilder<DatabaseEvent>(
              stream: db.getEventStream(eventId),
              builder: (context, eventSnap) {
                if (eventSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final raw = eventSnap.data?.snapshot.value;
                if (raw == null || raw is! Map) {
                  return const Center(
                    child: Text(
                      'Event tidak ditemukan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                final map = Map<String, dynamic>.from(raw);
                final event = EventModel.fromJson(map);

                final isOwner = (event.organizerId).trim() == userId;
                if (!isOwner) {
                  return Column(
                    children: [
                      const AppHeader(),
                      const SizedBox(height: 30),
                      const Icon(Icons.lock_outline, size: 40),
                      const SizedBox(height: 12),
                      const Text(
                        'Dashboard hanya untuk panitia',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Kamu bukan penyelenggara event ini.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => context.go(AppRoutes.home),
                        child: const Text(
                          'Kembali',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return StreamBuilder<DatabaseEvent>(
                  stream: FirebaseDatabase.instance
                      .ref('events/$eventId/rsvps')
                      .onValue,
                  builder: (context, rsvpSnap) {
                    if (rsvpSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    int totalRegistered = 0;
                    int totalAttended = 0;

                    final rsvpRaw = rsvpSnap.data?.snapshot.value;
                    if (rsvpRaw is Map) {
                      final m = Map<dynamic, dynamic>.from(rsvpRaw);
                      totalRegistered = m.length;

                      for (final entry in m.entries) {
                        final v = entry.value;
                        if (v is Map) {
                          final vm = Map<dynamic, dynamic>.from(v);
                          if (vm['attended'] == true) totalAttended++;
                        }
                      }
                    }

                    final notAttended = (totalRegistered - totalAttended).clamp(
                      0,
                      totalRegistered,
                    );
                    final total = totalRegistered == 0 ? 1 : totalRegistered;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppHeader(),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => context.go(AppRoutes.home),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_ios_new,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Dashboard Event',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    context.go(
                                      AppRoutes.scanner.replaceFirst(
                                        ':eventId',
                                        eventId,
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.qr_code_scanner,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Scan',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                            child: Text(
                              event.title,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                            child: Text(
                              event.organizerName,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: MetricCard(
                                    title: 'Total Pendaftar',
                                    value: totalRegistered.toString(),
                                    primaryColor: primaryColor,
                                    icon: Icons.people_outline,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: MetricCard(
                                    title: 'Total Kehadiran',
                                    value: totalAttended.toString(),
                                    primaryColor: primaryColor,
                                    icon: Icons.verified_outlined,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                border: Border.all(color: primaryColor),
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.pink.withAlpha(2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Visualisasi Kehadiran',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 140,
                                        height: 140,
                                        child: PieChart(
                                          values: [
                                            totalAttended.toDouble(),
                                            notAttended.toDouble(),
                                          ],
                                          colors: [
                                            primaryColor,
                                            const Color(0xFFFDE4E7),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            LegendRow(
                                              label: 'Hadir',
                                              value: totalAttended,
                                              total: totalRegistered,
                                              color: primaryColor,
                                            ),
                                            const SizedBox(height: 10),
                                            LegendRow(
                                              label: 'Belum Hadir',
                                              value: notAttended,
                                              total: totalRegistered,
                                              color: const Color(0xFFFDE4E7),
                                              valueColor: const Color(
                                                0xFFD64F5C,
                                              ),
                                            ),
                                            const SizedBox(height: 14),
                                            Text(
                                              totalRegistered == 0
                                                  ? 'Belum ada pendaftar.'
                                                  : 'Persentase hadir: ${((totalAttended / total) * 100).toStringAsFixed(0)}%',
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            child: Column(
                              children: [
                                CustomButton(
                                  text: 'Ubah Event',
                                  onPressed: () {
                                    context.go(
                                      AppRoutes.editEvent.replaceFirst(
                                        ':eventId',
                                        eventId,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                CustomButton(
                                  text: 'Hapus Event',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                          'Hapus Event?',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        content: const Text(
                                          'Event yang dihapus tidak bisa dikembalikan.',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text(
                                              'Batal',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text(
                                              'Hapus',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm != true) return;

                                    await DatabaseService().deleteEvent(
                                      eventId,
                                    );

                                    if (!context.mounted) return;
                                    context.go(AppRoutes.home);
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
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
}
