import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_role_service.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Manage Users",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade100, height: 1),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search users by email...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading users"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final email = (data["email"] ?? "").toString().toLowerCase();
                  return email.contains(_searchQuery.toLowerCase());
                }).toList();

                if (users.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                return ListView.separated(
                  itemCount: users.length,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  separatorBuilder: (c, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final doc = users[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final bool isAdmin = data["role"] == "admin";
                    final bool isCurrentUser =
                        doc.id == FirebaseAuth.instance.currentUser?.uid;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: isAdmin
                            ? Colors.black
                            : Colors.grey.shade200,
                        child: Icon(
                          isAdmin
                              ? Icons.admin_panel_settings
                              : Icons.person_outline,
                          color: isAdmin ? Colors.white : Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        data["email"] ?? "No Email",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        isAdmin ? "Administrator" : "User",
                        style: TextStyle(
                          color: isAdmin
                              ? Colors.green.shade700
                              : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      trailing: isCurrentUser
                          ? null // Cannot change own role
                          : TextButton(
                              onPressed: () => _toggleRole(doc.id, !isAdmin),
                              style: TextButton.styleFrom(
                                foregroundColor: isAdmin
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                              child: Text(
                                isAdmin ? "Demote" : "Make Admin",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleRole(String userId, bool makeAdmin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(makeAdmin ? "Promote to Admin?" : "Remove Admin Access?"),
        content: Text(
          makeAdmin
              ? "This user will have full access to manage events and payments."
              : "This user will lose access to admin features.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Confirm",
              style: TextStyle(
                color: makeAdmin ? Colors.blue : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (makeAdmin) {
        await UserRoleService.assignAdminRole(userId);
      } else {
        await UserRoleService.removeAdminRole(userId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              makeAdmin
                  ? "User promoted to Admin"
                  : "User demoted to regular User",
            ),
          ),
        );
      }
    }
  }
}
