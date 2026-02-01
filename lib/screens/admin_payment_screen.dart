import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/payment_service.dart';

class AdminPaymentScreen extends StatelessWidget {
  const AdminPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8FAFC);
    const primary = Color(0xFF111827);
    const secondary = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          /// ===== APP BAR =====
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: primary,
            elevation: 0,
            title: const Text(
              "Payment Approval",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          /// ===== SECTION TITLE =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                "Pending Payments",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ),
          ),

          /// ===== PAYMENT LIST =====
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("payments")
                .where("status", isEqualTo: "pending")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "No pending payments",
                      style: TextStyle(color: secondary),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return _PaymentCard(
                      paymentId: doc.id,
                      userId: data["userId"],
                      amount: data["amount"],
                      timestamp: data["timestamp"],
                    );
                  }, childCount: snapshot.data!.docs.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatefulWidget {
  final String paymentId;
  final String userId;
  final num amount;
  final Timestamp? timestamp;

  const _PaymentCard({
    required this.paymentId,
    required this.userId,
    required this.amount,
    required this.timestamp,
  });

  @override
  State<_PaymentCard> createState() => _PaymentCardState();
}

class _PaymentCardState extends State<_PaymentCard> {
  bool isApproving = false;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF111827);
    const secondary = Color(0xFF6B7280);
    const border = Color(0xFFE5E7EB);
    const success = Color(0xFF16A34A);
    final amount = widget.amount.toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// USER INFO
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(widget.userId)
                .get(),
            builder: (context, snap) {
              if (!snap.hasData || snap.data!.data() == null) {
                return const Text("Unknown User");
              }
              final user = snap.data!.data() as Map<String, dynamic>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user["name"] ?? "Unknown",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user["email"] ?? "",
                    style: const TextStyle(fontSize: 13, color: secondary),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          /// AMOUNT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Amount", style: TextStyle(color: secondary)),
              Text(
                "RM ${amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),

          if (widget.timestamp != null) ...[
            const SizedBox(height: 8),
            Text(
              _formatTimestamp(widget.timestamp!),
              style: const TextStyle(fontSize: 12, color: secondary),
            ),
          ],

          const SizedBox(height: 16),

          /// APPROVE BUTTON
          SizedBox(
            width: double.infinity,
            // Removed fixed height constraint
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: success,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isApproving
                  ? null
                  : () async {
                      setState(() => isApproving = true);
                      await PaymentService.approvePayment(widget.paymentId);
                    },
              child: isApproving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      "Approve Payment",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return "${date.day}/${date.month}/${date.year}";
  }
}
