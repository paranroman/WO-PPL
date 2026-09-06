import 'package:eventure/api/database_service.dart';
import 'package:eventure/providers/auth_provider.dart';
import 'package:eventure/widgets/app_header.dart';
import 'package:eventure/widgets/app_scaffold.dart';
import 'package:eventure/widgets/custom_button.dart';
import 'package:eventure/widgets/custom_textfield.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../navigation/app_router.dart';
import '../../widgets/event_card.dart';
import '../../widgets/show_qr_dialog.dart';
import '../../widgets/tab_pill.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tabIndex = 0;

  final TextEditingController _searchC = TextEditingController();
  bool _isSearching = false;
  Set<String>? _searchIds;

  bool _matchSearch(Map<dynamic, dynamic> e, String key) {
    if (_searchIds == null) return true;
    final id = ((e['id'] as String?) ?? key).trim();
    return _searchIds!.contains(id);
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    final screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (screenWidth - 40 - 12) / 2;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      controller: _searchC,
                      hintText: "Cari Event...",
                      icon: Icons.search,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: CustomButton(
                      text: _isSearching ? "..." : "Cari",
                      onPressed: _isSearching
                          ? null
                          : () async {
                              final q = _searchC.text.trim();
                              if (q.isEmpty) {
                                setState(() => _searchIds = null);
                                return;
                              }

                              setState(() => _isSearching = true);

                              try {
                                final res = await DatabaseService().cariEvent(
                                  q,
                                );
                                if (!mounted) return;
                                setState(() {
                                  _searchIds = res
                                      .map((e) => (e.id ?? '').trim())
                                      .where((id) => id.isNotEmpty)
                                      .toSet();
                                });
                              } finally {
                                if (!mounted) return;
                                setState(() => _isSearching = false);
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x1AD64A53)),
                ),
                child: Row(
                  children: [
                    TabPill(
                      text: "Diikuti",
                      isActive: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0),
                    ),
                    const SizedBox(width: 6),
                    TabPill(
                      text: "Dibuat",
                      isActive: _tabIndex == 1,
                      onTap: () => setState(() => _tabIndex = 1),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
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
                        "Silakan login terlebih dahulu",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return StreamBuilder<DatabaseEvent>(
                    stream: db.getAllEventsStream(),
                    builder: (context, eventSnap) {
                      if (eventSnap.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (eventSnap.hasError) {
                        return const Center(
                          child: Text("Terjadi kesalahan saat memuat event"),
                        );
                      }

                      final data = eventSnap.data?.snapshot.value;
                      if (data == null || data is! Map) {
                        return const Center(
                          child: Text(
                            "Belum ada event",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }

                      final raw = Map<dynamic, dynamic>.from(data);
                      final entries = raw.entries.toList();

                      if (_tabIndex == 1) {
                        final createdEntries = entries.where((entry) {
                          final v = entry.value;
                          if (v is! Map) return false;
                          final e = Map<dynamic, dynamic>.from(v);
                          final organizerId =
                              (e['organizerId'] as String?)?.trim() ?? '';
                          if (organizerId.isEmpty) return false;
                          return organizerId == userId &&
                              _matchSearch(e, entry.key.toString());
                        }).toList();

                        if (createdEntries.isEmpty) {
                          return const Center(
                            child: Text(
                              "Belum ada event dibuat",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }

                        return SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            bottom: 80,
                            left: 20,
                            right: 20,
                          ),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final entry in createdEntries)
                                Builder(
                                  builder: (_) {
                                    final key = entry.key.toString();
                                    final e = Map<dynamic, dynamic>.from(
                                      entry.value as Map,
                                    );

                                    final eventId =
                                        ((e['id'] as String?) ?? key).trim();
                                    final title =
                                        ((e['title'] as String?) ?? 'Event')
                                            .trim();

                                    return SizedBox(
                                      width: cardWidth,
                                      child: EventCard(
                                        imageUrl:
                                            (e['bannerUrl'] ?? '') as String,
                                        eventName: title,
                                        eventType:
                                            (e['eventType'] ?? '-') as String,
                                        price:
                                            (e['price'] ?? 'Gratis') as String,
                                        tags: (e['tags'] as String? ?? "")
                                            .split(",")
                                            .map((t) => t.trim())
                                            .where((t) => t.isNotEmpty)
                                            .toList(),
                                        showButton: false,
                                        cardClickable: true,
                                        onCardPressed: () {
                                          context.go(
                                            AppRoutes.eventDashboard
                                                .replaceFirst(
                                                  ':eventId',
                                                  eventId,
                                                ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        );
                      }

                      return StreamBuilder<Set<String>>(
                        stream: db.getRegisteredEvent(userId),
                        builder: (context, regSnap) {
                          if (regSnap.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (regSnap.hasError) {
                            return const Center(
                              child: Text("Gagal memuat data RSVP"),
                            );
                          }

                          final registeredSet = regSnap.data ?? <String>{};

                          final followedEntries = entries.where((entry) {
                            final key = entry.key.toString();
                            final v = entry.value;

                            if (v is! Map) return false;
                            final e = Map<dynamic, dynamic>.from(v);

                            final eventId = ((e['id'] as String?) ?? key)
                                .trim();
                            if (eventId.isEmpty) return false;

                            final organizerId =
                                (e['organizerId'] as String?)?.trim() ?? '';
                            if (organizerId == userId) return false;

                            return registeredSet.contains(eventId) &&
                                _matchSearch(e, key);
                          }).toList();

                          if (followedEntries.isEmpty) {
                            return const Center(
                              child: Text(
                                "Belum ada event diikuti",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            padding: const EdgeInsets.only(
                              bottom: 80,
                              left: 20,
                              right: 20,
                            ),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                for (final entry in followedEntries)
                                  Builder(
                                    builder: (_) {
                                      final key = entry.key.toString();
                                      final e = Map<dynamic, dynamic>.from(
                                        entry.value as Map,
                                      );

                                      final eventId =
                                          ((e['id'] as String?) ?? key).trim();
                                      final title =
                                          ((e['title'] as String?) ?? 'Event')
                                              .trim();

                                      return SizedBox(
                                        width: cardWidth,
                                        child: EventCard(
                                          imageUrl:
                                              (e['bannerUrl'] ?? '') as String,
                                          eventName: title,
                                          eventType:
                                              (e['eventType'] ?? '-') as String,
                                          price:
                                              (e['price'] ?? 'Gratis')
                                                  as String,
                                          tags: (e['tags'] as String? ?? "")
                                              .split(",")
                                              .map((t) => t.trim())
                                              .where((t) => t.isNotEmpty)
                                              .toList(),
                                          showButton: true,
                                          onButtonPressed: () {
                                            if (eventId.isEmpty) return;
                                            final qrData = '$eventId|$userId';
                                            showQrDialog(
                                              context,
                                              qrData,
                                              title,
                                              eventId,
                                            );
                                          },
                                          cardClickable: false,
                                        ),
                                      );
                                    },
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
          ],
        ),
      ),
    );
  }
}
