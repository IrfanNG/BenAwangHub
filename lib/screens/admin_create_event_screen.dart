import 'package:flutter/material.dart';
import '../services/translation_manager.dart';

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
  final List<String> _tempFamilies = [];

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
    // Required fields check
    if (titleController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        deadlineController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n('fill_required')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => isCreating = true);

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
        families: _tempFamilies,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n('event_created_success'))),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isCreating = false);
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
    // Leveraging the global AppTheme by default

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n('create_event')), centerTitle: true),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, context.l10n('event_details')),
                  const SizedBox(height: 16),

                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: context.l10n('event_title_label'),
                      hintText: context.l10n('event_title_hint'),
                    ),
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
                        // Formatting to YYYY-MM-DD
                        String formattedDate =
                            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        setState(() {
                          dateController.text = formattedDate;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: context.l10n('event_date_label'),
                      hintText: "YYYY-MM-DD",
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: "${context.l10n('location')} *",
                      hintText: "e.g. Port Dickson",
                    ),
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
                    decoration: InputDecoration(
                      labelText: context.l10n('reg_deadline_label'),
                      hintText: "YYYY-MM-DD",
                    ),
                  ),
                  const SizedBox(height: 16),

                  CheckboxListTile(
                    value: hasLuckyDraw,
                    onChanged: (val) {
                      setState(() => hasLuckyDraw = val ?? false);
                    },
                    title: Text(context.l10n('enable_lucky_draw')),
                    subtitle: Text(
                      context.l10n('lucky_draw_desc'),
                    ),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: () => _showManageCategoriesDialog(context),
                    icon: const Icon(Icons.category),
                    label: Text(context.l10n('manage_categories')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 32),
                  _sectionTitle(context, context.l10n('pricing_optional')),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: adultFeeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: context.l10n('adult_fee_label'),
                            hintText: "0.00",
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
                          decoration: InputDecoration(
                            labelText: context.l10n('child_fee_label'),
                            hintText: "0.00",
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isCreating ? null : _createEvent,
                      child: isCreating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(context.l10n('create_event')),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  void _showManageCategoriesDialog(BuildContext context) {
    final TextEditingController newCatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(context.l10n('manage_categories')),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newCatController,
                          decoration: InputDecoration(
                            hintText: context.l10n('new_category_name'),
                            isDense: true,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Colors.black,
                          size: 32,
                        ),
                        onPressed: () {
                          if (newCatController.text.trim().isNotEmpty) {
                            setDialogState(() {
                              _tempFamilies.add(newCatController.text.trim());
                              newCatController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  Expanded(
                    child: _tempFamilies.isEmpty
                        ? Center(child: Text(context.l10n('no_categories_added')))
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: _tempFamilies.length,
                            separatorBuilder: (c, i) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final name = _tempFamilies[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(name),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setDialogState(() {
                                      _tempFamilies.removeAt(index);
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n('done')),
              ),
            ],
          );
        },
      ),
    );
  }
}
