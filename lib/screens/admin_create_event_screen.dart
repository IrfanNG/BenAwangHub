import 'package:flutter/material.dart';
import '../services/event_service.dart';

class AdminCreateEventScreen extends StatefulWidget {
  const AdminCreateEventScreen({super.key});

  @override
  State<AdminCreateEventScreen> createState() => _AdminCreateEventScreenState();
}

class _AdminCreateEventScreenState extends State<AdminCreateEventScreen> {
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final locationController = TextEditingController();
  final adultFeeController = TextEditingController();
  final childFeeController = TextEditingController();
  final deadlineController = TextEditingController();

  bool isCreating = false;
  bool hasLuckyDraw = false;

  @override
  void dispose() {
    titleController.dispose();
    dateController.dispose();
    locationController.dispose();
    adultFeeController.dispose();
    childFeeController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    /// REQUIRED FIELDS ONLY
    if (titleController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        deadlineController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in required fields")),
      );
      return;
    }

    setState(() => isCreating = true);

    /// ⭐ SAFE PARSING (FREE EVENT SUPPORTED)
    final double adultFee =
        double.tryParse(adultFeeController.text.trim()) ?? 0.0;
    final double childFee =
        double.tryParse(childFeeController.text.trim()) ?? 0.0;

    try {
      await EventService.createEvent(
        title: titleController.text.trim(),
        date: dateController.text.trim(),
        location: locationController.text.trim(),
        adultFee: adultFee,
        childFee: childFee,
        deadline: deadlineController.text.trim(),
        hasLuckyDraw: hasLuckyDraw,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8FAFC);
    const primary = Color(0xFF111827);
    const accent = Color(0xFF374151);
    const border = Color(0xFFE5E7EB);

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
              "Create Event",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          /// ===== FORM =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Event Details"),

                  _field(
                    controller: titleController,
                    label: "Event Title *",
                    hint: "Family Day 2026",
                  ),
                  _field(
                    controller: dateController,
                    label: "Event Date *",
                    hint: "2026-06-10",
                  ),
                  _field(
                    controller: locationController,
                    label: "Location *",
                    hint: "Port Dickson",
                  ),
                  _field(
                    controller: deadlineController,
                    label: "Registration Deadline *",
                    hint: "2026-05-20",
                  ),

                  CheckboxListTile(
                    value: hasLuckyDraw,
                    onChanged: (val) {
                      setState(() => hasLuckyDraw = val ?? false);
                    },
                    title: const Text(
                      "Enable Cabutan Bertuah",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text(
                      "Participants will receive a random 3-digit lucky number",
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),

                  const SizedBox(height: 24),
                  _sectionTitle("Pricing (Optional)"),

                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          controller: adultFeeController,
                          label: "Adult Fee (RM)",
                          hint: "Leave empty if free",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          controller: childFeeController,
                          label: "Child Fee (RM)",
                          hint: "Leave empty if free",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isCreating ? null : _createEvent,
                      child: isCreating
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text(
                              "Create Event",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ===== UI COMPONENTS =====

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF111827),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
