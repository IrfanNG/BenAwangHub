import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
=======
import 'package:qr_flutter/qr_flutter.dart';
>>>>>>> a9715c3b08abbe02e217ceee16cfbb2ddd07cbb1
import 'admin_attendance_screen.dart';
import 'lucky_draw_screen.dart';

class AdminEventSummaryScreen extends StatefulWidget {
  final String eventId;

  const AdminEventSummaryScreen({super.key, required this.eventId});

  @override
  State<AdminEventSummaryScreen> createState() =>
      _AdminEventSummaryScreenState();
}

class _AdminEventSummaryScreenState extends State<AdminEventSummaryScreen> {
  int winnerCount = 1;

<<<<<<< HEAD
  /// ===== ADMIN CHECK-IN CODE =====
  Widget buildAdminCheckInCode(String code) {
    return Column(
      children: [
        Text(
          code,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            letterSpacing: 8,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Share this code to check in",
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
=======
  /// ===== ADMIN QR =====
  Widget buildAdminQR(String eventId) {
    return Column(
      children: [
        QrImageView(data: eventId, size: 200),
        const SizedBox(height: 8),
        const Text(
          "Scan this QR to check in",
          style: TextStyle(color: Color(0xFF6B7280)),
>>>>>>> a9715c3b08abbe02e217ceee16cfbb2ddd07cbb1
        ),
      ],
    );
  }

<<<<<<< HEAD
  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Avoid ambiguous chars
    final rnd = DateTime.now().millisecondsSinceEpoch;
    return List.generate(6, (index) {
      final charIndex = (rnd + index * 31) % chars.length;
      return chars[charIndex];
    }).join();
  }

=======
  @override
>>>>>>> a9715c3b08abbe02e217ceee16cfbb2ddd07cbb1
  @override
  Widget build(BuildContext context) {
    const bg = Colors.white; // Pure white background
    // const card = Colors.white; // Not used if we remove cards
    // const primary = Color(0xFF111827); // Dark Slate

    return Scaffold(
      backgroundColor: bg,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("events")
            .doc(widget.eventId)
            .collection("registrations")
            .snapshots(),
        builder: (context, regSnap) {
          if (!regSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("payments")
                .where("eventId", isEqualTo: widget.eventId)
                .where("status", isEqualTo: "approved")
                .snapshots(),
            builder: (context, paySnap) {
              if (!paySnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final paidUsers = {
                for (var p in paySnap.data!.docs)
                  (p.data() as Map<String, dynamic>)["userId"]: true,
              };

              int totalAdults = 0;
              int totalKids = 0;
              int paidCount = 0;

              for (var doc in regSnap.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                totalAdults += (data["adults"] ?? 0) as int;
                totalKids += (data["kids"] ?? 0) as int;
                if (paidUsers.containsKey(doc.id)) paidCount++;
              }

              return CustomScrollView(
                slivers: [
                  /// APP BAR
                  const SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    centerTitle: true,
                    title: Text(
                      "Event Summary",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),

                  /// CONTENT
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// CHECK-IN SECTION
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("events")
                                .doc(widget.eventId)
                                .snapshots(),
                            builder: (context, snap) {
                              if (!snap.hasData || snap.data!.data() == null) {
                                return const SizedBox();
                              }

                              final event =
                                  snap.data!.data() as Map<String, dynamic>;
                              final isActive = event["checkInActive"] == true;

                              if (!isActive) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.qr_code_scanner,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Ready to start?",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection("events")
                                                .doc(widget.eventId)
                                                .update({
                                                  "checkInActive": true,
<<<<<<< HEAD
                                                  "checkInCode":
                                                      _generateCode(),
=======
>>>>>>> a9715c3b08abbe02e217ceee16cfbb2ddd07cbb1
                                                  "winnerCount": winnerCount,
                                                });
                                          },
                                          child: const Text("Start Check-In"),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Center(
<<<<<<< HEAD
                                child: buildAdminCheckInCode(
                                  event["checkInCode"] ?? "------",
                                ),
=======
                                child: buildAdminQR(widget.eventId),
>>>>>>> a9715c3b08abbe02e217ceee16cfbb2ddd07cbb1
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          /// STATS GRID
                          const Text(
                            "Overview",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: "Adults",
                                  value: totalAdults.toString(),
                                  icon: Icons.person,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  label: "Kids",
                                  value: totalKids.toString(),
                                  icon: Icons.child_care,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: "Total Guests",
                                  value: (totalAdults + totalKids).toString(),
                                  icon: Icons.groups,
                                  highlight: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  label: "Paid",
                                  value:
                                      "$paidCount/${regSnap.data!.docs.length}",
                                  icon: Icons.payments,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          /// ACTIONS LIST
                          const Text(
                            "Actions",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _ActionTile(
                            icon: Icons.list_alt,
                            title: "View Attendance List",
                            subtitle: "Check who is here",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminAttendanceScreen(
                                    eventId: widget.eventId,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _ActionTile(
                            icon: Icons.casino,
                            title: "Lucky Draw Room",
                            subtitle: "Run the lucky draw",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      LuckyDrawScreen(eventId: widget.eventId),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: highlight ? Colors.black : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: highlight ? Colors.white70 : Colors.grey),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.white : Colors.black,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: highlight ? Colors.white54 : Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.black),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
