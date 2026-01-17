import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AdminEventSummaryScreen extends StatelessWidget {
  final String eventId;

  const AdminEventSummaryScreen({super.key, required this.eventId});

  /// ===== ADMIN QR (LOGIC UNCHANGED) =====
  Widget buildAdminQR(String eventId) {
    return Column(
      children: [
        QrImageView(
          data: eventId,
          size: 200,
        ),
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
    const secondary = Color(0xFF6B7280);
    const accent = Color(0xFF374151);
    const border = Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bg,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("events")
            .doc(eventId)
            .collection("registrations")
            .snapshots(),
        builder: (context, regSnap) {
          if (!regSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("payments")
                .where("eventId", isEqualTo: eventId)
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
              double totalAmount = 0;
              int paidCount = 0;

              for (var doc in regSnap.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                totalAdults += (data["adults"] ?? 0) as int;
                totalKids += (data["kids"] ?? 0) as int;
                totalAmount += (data["total"] ?? 0).toDouble();
                if (paidUsers.containsKey(doc.id)) paidCount++;
              }

              return CustomScrollView(
                slivers: [
                  /// ===== APP BAR =====
                  SliverAppBar(
                    expandedHeight: 120,
                    pinned: true,
                    backgroundColor: Colors.white,
                    foregroundColor: primary,
                    elevation: 0,
                    flexibleSpace: const FlexibleSpaceBar(
                      title: Text(
                        "Event Summary",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  /// ===== SUMMARY =====
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
                                  .doc(eventId)
                                  .snapshots(),
                              builder: (context, snap) {
                                if (!snap.hasData ||
                                    snap.data!.data() == null) {
                                  return const SizedBox();
                                }

                                final data =
                                    snap.data!.data() as Map<String, dynamic>;
                                final isActive =
                                    data["checkInActive"] == true;

                                if (!isActive) {
                                  return _primaryButton(
                                    label: "Start Check-In",
                                    icon: Icons.qr_code,
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection("events")
                                          .doc(eventId)
                                          .update({"checkInActive": true});
                                    },
                                  );
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Check-in Active",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: primary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    buildAdminQR(eventId),
                                  ],
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

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
                        ],
                      ),
                    ),
                  ),

                  /// ===== REGISTRATION LIST =====
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final doc = regSnap.data!.docs[index];
                          final data =
                              doc.data() as Map<String, dynamic>;
                          final paid =
                              paidUsers.containsKey(doc.id);

                          return _RegistrationCard(
                            eventId: eventId,
                            userId: doc.id,
                            total: (data["total"] ?? 0).toDouble(),
                            isPaid: paid,
                          );
                        },
                        childCount: regSnap.data!.docs.length,
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

/// ===== STAT CARD (UI ONLY) =====
class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

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
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

/// ===== REGISTRATION CARD (ATTENDANCE LOGIC KEKAL) =====
class _RegistrationCard extends StatelessWidget {
  final String eventId;
  final String userId;
  final double total;
  final bool isPaid;

  const _RegistrationCard({
    required this.eventId,
    required this.userId,
    required this.total,
    required this.isPaid,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        isPaid ? const Color(0xFF374151) : const Color(0xFF9CA3AF);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(
            isPaid ? Icons.check_circle : Icons.pending,
            color: statusColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("users")
                      .doc(userId)
                      .get(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Text(
                        "Loading...",
                        style: TextStyle(fontSize: 14),
                      );
                    }

                    if (!snap.data!.exists) {
                      return const Text(
                        "Unknown User",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }

                    final user = snap.data!.data() as Map<String, dynamic>;

                    return Text(
                      user["name"] ?? "Unnamed User",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3142),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),

                /// ATTENDANCE (LOGIC UNCHANGED)
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("attendance")
                      .doc("${eventId}_$userId")
                      .get(),
                  builder: (context, snap) {
                    final present =
                        snap.hasData && snap.data!.exists;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: present
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        present ? "Present" : "Absent",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              present ? Colors.green : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Text(
            "RM ${total.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
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
