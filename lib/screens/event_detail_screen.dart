import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/registration_service.dart';
import '../services/payment_service.dart';
import '../services/user_role_service.dart';
import 'admin_event_summary_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  int adults = 1;
  int kids = 0;
  final TextEditingController _codeController = TextEditingController();
  bool _isCheckingIn = false;

  String? _selectedFamily;
  final List<String> _families = [
    "Makngah biah",
    "Pak Long",
    "Mak Su",
    "Pak Ngah",
    "Tok Wan",
    "Opah",
  ];

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Event Details",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade100, height: 1),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("events")
            .doc(widget.eventId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("Event not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final double adultFee = (data["adultFee"] ?? 0).toDouble();
          final double childFee = (data["childFee"] ?? 0).toDouble();
          final double total = (adults * adultFee) + (kids * childFee);
          final bool isPaidEvent = adultFee > 0 || childFee > 0;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              /// HEADER INFO
              Text(
                data["title"] ?? "Untitled",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Date & Time",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data["date"] ?? "TBA",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Location",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data["location"] ?? "TBA",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              const Divider(height: 1),
              const SizedBox(height: 32),

              /// REGISTRATION SECTION
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("events")
                    .doc(widget.eventId)
                    .collection("registrations")
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, regSnap) {
                  final isRegistered = regSnap.hasData && regSnap.data!.exists;

                  if (isRegistered) {
                    final regData =
                        regSnap.data!.data() as Map<String, dynamic>;
                    final status = regData["status"];

                    // PENDING PAYMENT STATE
                    if (status == "pending_payment") {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.orange.shade800,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Payment Required",
                                      style: TextStyle(
                                        color: Colors.orange.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "You have successfully booked your slot. Please complete the payment to finalize your registration.",
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Total Amount",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      "RM ${(regData["total"] ?? 0).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(27),
                                      ),
                                    ),
                                    onPressed: () => _handlePayment(
                                      context,
                                      (regData["total"] ?? 0).toDouble(),
                                      widget.eventId,
                                    ),
                                    child: const Text(
                                      "I Have Paid",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildCheckInSection(context, data),
                        ],
                      );
                    }

                    // REGISTERED STATE
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.how_to_reg,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Registered",
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Status: ${status?.toUpperCase() ?? "REGISTERED"}",
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${regData["adults"] ?? 0} Adults, ${regData["kids"] ?? 0} Kids",
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildCheckInSection(context, data),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// FAMILY SELECTION
                      Text(
                        "Category",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedFamily,
                        decoration: InputDecoration(
                          hintText: "Select Family",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: _families.map((f) {
                          return DropdownMenuItem(value: f, child: Text(f));
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedFamily = val),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        "Who's attending?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _counter("Adults", adults, () {
                        if (adults > 1) setState(() => adults--);
                      }, () => setState(() => adults++)),
                      const SizedBox(height: 16),
                      _counter("Kids", kids, () {
                        if (kids > 0) setState(() => kids--);
                      }, () => setState(() => kids++)),
                      const SizedBox(height: 32),

                      /// TOTAL (PAID EVENT ONLY)
                      if (isPaidEvent) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total Amount",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                "RM ${total.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      /// REGISTER BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            ),
                          ),
                          onPressed: () => _handleRegistration(
                            context,
                            adultFee,
                            childFee,
                            widget.eventId,
                          ),
                          child: const Text(
                            "Confirm Registration",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// PAYMENT BUTTON
                      if (isPaidEvent)
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                            onPressed: () =>
                                _handlePayment(context, total, widget.eventId),
                            child: const Text(
                              "I Have Paid",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              /// CHECK-IN SECTION
              const SizedBox(height: 24),

              const SizedBox(height: 24),

              /// LUCKY NUMBER SECTION
              _buildLuckyNumberSection(context),

              const SizedBox(height: 24),

              /// ADMIN ONLY
              FutureBuilder<bool>(
                future: UserRoleService.isAdmin(),
                builder: (context, snap) {
                  if (snap.data != true) return const SizedBox();
                  return Column(
                    children: [
                      const Divider(),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        icon: const Icon(Icons.dashboard_outlined),
                        label: const Text("Manage Event (Admin)"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
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
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _counter(
    String label,
    int value,
    VoidCallback minus,
    VoidCallback plus,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: minus,
                icon: Icon(Icons.remove, size: 18, color: Colors.grey.shade800),
                visualDensity: VisualDensity.compact,
              ),
              SizedBox(
                width: 32,
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: plus,
                icon: Icon(Icons.add, size: 18, color: Colors.grey.shade800),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegistration(
    BuildContext context,
    double adultFee,
    double childFee,
    String eventId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login first")));
      return;
    }

    if (_selectedFamily == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a family")));
      return;
    }
    try {
      await RegistrationService.register(
        eventId: eventId,
        userId: user.uid,
        adults: adults,
        kids: kids,
        adultFee: adultFee,
        childFee: childFee,
        familyName: _selectedFamily,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registered successfully")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _handlePayment(
    BuildContext context,
    double total,
    String eventId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await PaymentService.submitPayment(
        eventId: eventId,
        userId: user.uid,
        amount: total,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment submitted linked to registration"),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Widget _buildCheckInSection(
    BuildContext context,
    Map<String, dynamic> event,
  ) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return FutureBuilder<bool>(
      future: UserRoleService.isAdmin(),
      builder: (context, adminSnap) {
        if (adminSnap.data == true) return const SizedBox();

        final bool checkInActive = event["checkInActive"] == true;
        if (!checkInActive) return const SizedBox();

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("events")
              .doc(widget.eventId)
              .collection("registrations")
              .doc(user.uid)
              .snapshots(),
          builder: (context, snap) {
            if (snap.hasData &&
                snap.data!.exists &&
                (snap.data!.data() as Map<String, dynamic>)["checkedInAt"] !=
                    null) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Text(
                      "You are checked in",
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "EVENT CHECK-IN",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      hintText: "Enter 6-digit code",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isCheckingIn
                          ? null
                          : () => _handleCheckIn(context, event["checkInCode"]),
                      child: _isCheckingIn
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Check In"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleCheckIn(BuildContext context, String? correctCode) async {
    final input = _codeController.text.trim().toUpperCase();
    if (input.isEmpty) return;

    if (correctCode == null || input != correctCode) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid check-in code")));
      return;
    }

    setState(() => _isCheckingIn = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection("events")
          .doc(widget.eventId)
          .collection("registrations")
          .doc(user.uid)
          .update({"checkedInAt": FieldValue.serverTimestamp()});

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Check-in successful!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isCheckingIn = false);
    }
  }

  Widget _buildLuckyNumberSection(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("events")
          .doc(widget.eventId)
          .collection("registrations")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) return const SizedBox();
        final reg = snap.data!.data() as Map<String, dynamic>;
        final List<dynamic>? luckyNumbers = reg["luckyNumbers"];
        final String? legacyLuckyNumber = reg["luckyNumber"];
        String displayString = "";
        if (luckyNumbers != null && luckyNumbers.isNotEmpty) {
          displayString = luckyNumbers.join(", ");
        } else if (legacyLuckyNumber != null) {
          displayString = legacyLuckyNumber;
        } else {
          return const SizedBox();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "YOUR LUCKY NUMBERS",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.amber.shade900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                displayString,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.amber.shade900,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
