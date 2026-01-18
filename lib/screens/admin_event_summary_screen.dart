import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'admin_attendance_screen.dart';
import '../services/lucky_draw_service.dart';

class AdminEventSummaryScreen extends StatefulWidget {
  final String eventId;

  const AdminEventSummaryScreen({super.key, required this.eventId});

  @override
  State<AdminEventSummaryScreen> createState() =>
      _AdminEventSummaryScreenState();
}

class _AdminEventSummaryScreenState extends State<AdminEventSummaryScreen> {
  int winnerCount = 1;

  /// ===== ADMIN QR =====
  Widget buildAdminQR(String eventId) {
    return Column(
      children: [
        QrImageView(data: eventId, size: 200),
        const SizedBox(height: 8),
        const Text(
          "Scan this QR to check in",
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8FAFC);
    const card = Colors.white;
    const primary = Color(0xFF111827);
    const border = Color(0xFFE5E7EB);

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
                  (p.data() as Map<String, dynamic>)["userId"]: true
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
                    foregroundColor: primary,
                    elevation: 0,
                    title: Text(
                      "Event Summary",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),

                  /// CONTENT
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// CHECK-IN
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: border),
                            ),
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("events")
                                  .doc(widget.eventId)
                                  .snapshots(),
                              builder: (context, snap) {
                                if (!snap.hasData ||
                                    snap.data!.data() == null) {
                                  return const SizedBox();
                                }

                                final event =
                                    snap.data!.data() as Map<String, dynamic>;
                                final isActive =
                                    event["checkInActive"] == true;

                                if (!isActive) {
                                  return _primaryButton(
                                    label: "Start Check-In",
                                    icon: Icons.qr_code,
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection("events")
                                          .doc(widget.eventId)
                                          .update({
                                        "checkInActive": true,
                                        "winnerCount": winnerCount,
                                      });
                                    },
                                  );
                                }

                                return buildAdminQR(widget.eventId);
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// ATTENDANCE
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade800,
                              foregroundColor: Colors.white,
                              minimumSize:
                                  const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.fact_check),
                            label: const Text("View Attendance List"),
                            onPressed: () {
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

                          const SizedBox(height: 24),

                          /// STATS
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: "Adults",
                                  value: totalAdults.toString(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  label: "Kids",
                                  value: totalKids.toString(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: "Total People",
                                  value:
                                      (totalAdults + totalKids).toString(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  label: "Paid",
                                  value:
                                      "$paidCount/${regSnap.data!.docs.length}",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          /// 🎯 WINNER SETTING
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: border),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Number of Winners",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        if (winnerCount > 1) {
                                          setState(() => winnerCount--);
                                        }
                                      },
                                    ),
                                    Text(
                                      winnerCount.toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setState(() => winnerCount++);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _primaryButton(
                                  label: "Pick Winners",
                                  icon: Icons.emoji_events,
                                  onPressed: () async {
                                    try {
                                      await LuckyDrawService.pickWinners(
                                        widget.eventId,
                                        winnerCount,
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "🎉 Winners picked successfully"),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(e.toString()),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
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

/// ===== STAT CARD =====
class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

/// ===== BUTTON =====
Widget _primaryButton({
  required String label,
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF374151),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: onPressed,
    ),
  );
}
