import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEditEventScreen extends StatefulWidget {
  final String eventId;

  const AdminEditEventScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<AdminEditEventScreen> createState() => _AdminEditEventScreenState();
}

class _AdminEditEventScreenState extends State<AdminEditEventScreen> {
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final locationController = TextEditingController();
  final deadlineController = TextEditingController();
  final adultFeeController = TextEditingController();
  final childFeeController = TextEditingController();

  bool hasLuckyDraw = false;
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    final doc = await FirebaseFirestore.instance
        .collection("events")
        .doc(widget.eventId)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    titleController.text = data["title"] ?? "";
    dateController.text = data["date"] ?? "";
    locationController.text = data["location"] ?? "";
    deadlineController.text = data["deadline"] ?? "";

    adultFeeController.text =
        (data["adultFee"] ?? 0).toString();
    childFeeController.text =
        (data["childFee"] ?? 0).toString();

    hasLuckyDraw = data["hasLuckyDraw"] == true;

    setState(() => loading = false);
  }

  Future<void> _save() async {
    if (titleController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        deadlineController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill required fields")),
      );
      return;
    }

    setState(() => saving = true);

    final adultFee =
        double.tryParse(adultFeeController.text.trim()) ?? 0;
    final childFee =
        double.tryParse(childFeeController.text.trim()) ?? 0;

    await FirebaseFirestore.instance
        .collection("events")
        .doc(widget.eventId)
        .update({
      "title": titleController.text.trim(),
      "date": dateController.text.trim(),
      "location": locationController.text.trim(),
      "deadline": deadlineController.text.trim(),
      "adultFee": adultFee,
      "childFee": childFee,
      "hasLuckyDraw": hasLuckyDraw,
      "updatedAt": Timestamp.now(),
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event updated")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8FAFC);
    const primary = Color(0xFF111827);
    const accent = Color(0xFF374151);
    const border = Color(0xFFE5E7EB);

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          "Edit Event",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section("Event Details"),

            _field(titleController, "Event Title *"),
            _field(dateController, "Event Date *"),
            _field(locationController, "Location *"),
            _field(deadlineController, "Registration Deadline *"),

            CheckboxListTile(
              value: hasLuckyDraw,
              onChanged: (v) => setState(() => hasLuckyDraw = v ?? false),
              title: const Text(
                "Enable Cabutan Bertuah",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            const SizedBox(height: 24),
            _section("Pricing (Optional)"),

            Row(
              children: [
                Expanded(
                  child: _field(
                    adultFeeController,
                    "Adult Fee (RM)",
                    type: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    childFeeController,
                    "Child Fee (RM)",
                    type: TextInputType.number,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: saving ? null : _save,
                child: saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        "Save Changes",
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
    );
  }

  /// ===== UI HELPERS =====

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType type = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
