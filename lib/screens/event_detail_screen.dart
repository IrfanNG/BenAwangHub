import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/registration_service.dart';
import '../services/payment_service.dart';
import '../services/user_role_service.dart';
import 'admin_event_summary_screen.dart';
import 'qr_scan_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  int adults = 1;
  int kids = 0;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8FAFC);
    const card = Colors.white;
    const primary = Color(0xFF111827);
    const secondary = Color(0xFF6B7280);
    const accent = Color(0xFF374151);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Event Detail"),
        backgroundColor: Colors.white,
        foregroundColor: primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("events")
            .doc(widget.eventId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final double adultFee = (data["adultFee"] ?? 0).toDouble();
          final double childFee = (data["childFee"] ?? 0).toDouble();
          final double total = (adults * adultFee) + (kids * childFee);

          /// ⭐ IMPORTANT FLAG
          final bool isPaidEvent = adultFee > 0 || childFee > 0;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// EVENT HEADER
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["title"],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${data["date"]} • ${data["location"]}",
                        style: const TextStyle(color: secondary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  "Who's coming?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),

                const SizedBox(height: 16),

                _counter("Adults", adults,
                    () => setState(() {
                          if (adults > 1) adults--;
                        }),
                    () => setState(() => adults++)),

                const SizedBox(height: 12),

                _counter("Kids", kids,
                    () => setState(() {
                          if (kids > 0) kids--;
                        }),
                    () => setState(() => kids++)),

                const SizedBox(height: 20),

                /// TOTAL (PAID EVENT ONLY)
                if (isPaidEvent) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primary,
                          ),
                        ),
                        Text(
                          "RM ${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const Spacer(),

                /// REGISTER (ALWAYS)
                _primaryButton(
                  label: "Register",
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    await RegistrationService.register(
                      eventId: widget.eventId,
                      userId: user.uid,
                      adults: adults,
                      kids: kids,
                      adultFee: adultFee,
                      childFee: childFee,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Registered successfully"),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                /// PAYMENT (PAID EVENT ONLY)
                if (isPaidEvent)
                  _secondaryButton(
                    label: "I Have Paid",
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;

                      await PaymentService.submitPayment(
                        eventId: widget.eventId,
                        userId: user.uid,
                        amount: total,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Payment submitted"),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 20),

                const Divider(),

                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("events")
                      .doc(widget.eventId)
                      .collection("registrations")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),
                  builder: (context, snap) {
                    if (!snap.hasData || !snap.data!.exists) {
                      return const SizedBox();
                    }

                    final reg = snap.data!.data() as Map<String, dynamic>;
                    final luckyNumber = reg["luckyNumber"];

                    if (luckyNumber == null) return const SizedBox();

                    return Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Lucky Number",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            luckyNumber,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF374151),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                /// USER CHECK-IN
                FutureBuilder<bool>(
                  future: UserRoleService.isAdmin(),
                  builder: (context, snap) {
                    if (snap.data == true) return const SizedBox();

                    return TextButton.icon(
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text("Scan Check-In QR"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QrScanScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),

                /// ADMIN SUMMARY
                FutureBuilder<bool>(
                  future: UserRoleService.isAdmin(),
                  builder: (context, snap) {
                    if (snap.data != true) return const SizedBox();

                    return _primaryButton(
                      label: "View Event Summary",
                      icon: Icons.analytics,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminEventSummaryScreen(
                              eventId: widget.eventId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ===== COUNTER =====
  Widget _counter(
    String label,
    int value,
    VoidCallback minus,
    VoidCallback plus,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              IconButton(onPressed: minus, icon: const Icon(Icons.remove)),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(onPressed: plus, icon: const Icon(Icons.add)),
            ],
          )
        ],
      ),
    );
  }

  /// ===== BUTTONS =====
  Widget _primaryButton({
    required String label,
    IconData? icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: icon != null ? Icon(icon) : const SizedBox(),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF374151),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _secondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF374151),
          side: const BorderSide(color: Color(0xFF374151)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  /// ===== USER QR (UNCHANGED, FUTURE USE) =====
  Widget buildUserQR(String eventId, String userId) {
    final qrData = "$eventId|$userId";

    return Column(
      children: [
        const Text(
          "Your Event QR",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        QrImageView(data: qrData, size: 200),
        const SizedBox(height: 8),
        const Text(
          "Show this at the entrance",
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}
