import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFamilyMembersScreen extends StatefulWidget {
  final String familyName;
  final List<QueryDocumentSnapshot> registrations;

  const AdminFamilyMembersScreen({
    super.key,
    required this.familyName,
    required this.registrations,
  });

  @override
  State<AdminFamilyMembersScreen> createState() =>
      _AdminFamilyMembersScreenState();
}

class _AdminFamilyMembersScreenState extends State<AdminFamilyMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "${widget.familyName} Members",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search members...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.registrations.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final regDoc = widget.registrations[index];
                return _FamilyMemberTile(
                  regDoc: regDoc,
                  searchQuery: _searchQuery,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyMemberTile extends StatelessWidget {
  final QueryDocumentSnapshot regDoc;
  final String searchQuery;

  const _FamilyMemberTile({required this.regDoc, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final data = regDoc.data() as Map<String, dynamic>;
    final userId = regDoc.id;
    final int adults = (data["adults"] ?? 0) as int;
    final int kids = (data["kids"] ?? 0) as int;
    final isPresent = data["checkedInAt"] != null;
    final checkedInAt = data["checkedInAt"] as Timestamp?;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection("users").doc(userId).get(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) return const SizedBox();

        final userData = userSnap.data!.data() as Map<String, dynamic>?;
        final name = userData?["name"] ?? "Unknown";

        // Filter here if search query is active
        if (searchQuery.isNotEmpty &&
            !name.toLowerCase().contains(searchQuery)) {
          return const SizedBox.shrink();
        }

        final initials = name.isNotEmpty
            ? name.trim().split(' ').take(2).map((e) => e[0]).join()
            : "?";

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isPresent
                    ? Colors.green.shade50
                    : Colors.grey.shade100,
                child: Text(
                  initials.toUpperCase(),
                  style: TextStyle(
                    color: isPresent
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$adults Adults, $kids Kids",
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPresent
                          ? "Checked in at ${_formatTime(checkedInAt)}"
                          : "Not checked in",
                      style: TextStyle(
                        color: isPresent ? Colors.green : Colors.red.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPresent)
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return "";
    final d = ts.toDate();
    return "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }
}
