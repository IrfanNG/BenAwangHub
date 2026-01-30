import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEditEventScreen extends StatefulWidget {
  final String eventId;

  const AdminEditEventScreen({super.key, required this.eventId});

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

  @override
  void dispose() {
    titleController.dispose();
    dateController.dispose();
    locationController.dispose();
    deadlineController.dispose();
    adultFeeController.dispose();
    childFeeController.dispose();
    super.dispose();
  }

  Future<void> _loadEvent() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("events")
          .doc(widget.eventId)
          .get();

      if (!doc.exists) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final data = doc.data()!;

      titleController.text = data["title"] ?? "";
      dateController.text = data["date"] ?? "";
      locationController.text = data["location"] ?? "";
      deadlineController.text = data["deadline"] ?? "";

      adultFeeController.text = (data["adultFee"] ?? 0).toString();
      childFeeController.text = (data["childFee"] ?? 0).toString();

      hasLuckyDraw = data["hasLuckyDraw"] == true;
    } catch (e) {
      debugPrint("Error loading event: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _save() async {
    if (titleController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        deadlineController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill required fields"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => saving = true);

    final adultFee = double.tryParse(adultFeeController.text.trim()) ?? 0;
    final childFee = double.tryParse(childFeeController.text.trim()) ?? 0;

    try {
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
          const SnackBar(content: Text("Event updated successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Event"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, "Event Details"),
            const SizedBox(height: 16),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Event Title *"),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: dateController,
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  String formattedDate =
                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                  setState(() {
                    dateController.text = formattedDate;
                  });
                }
              },
              decoration: const InputDecoration(labelText: "Event Date *"),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "Location *"),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: deadlineController,
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  String formattedDate =
                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                  setState(() {
                    deadlineController.text = formattedDate;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: "Registration Deadline *",
              ),
            ),
            const SizedBox(height: 16),

            CheckboxListTile(
              value: hasLuckyDraw,
              onChanged: (v) => setState(() => hasLuckyDraw = v ?? false),
              title: const Text("Enable Cabutan Bertuah"),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 32),
            _sectionTitle(context, "Pricing (Optional)"),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: adultFeeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Adult Fee (RM)",
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: childFeeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Child Fee (RM)",
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : _save,
                child: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Save Changes"),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
