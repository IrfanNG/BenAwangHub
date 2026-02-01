import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'about_app_screen.dart';
import '../services/user_role_service.dart';
import 'admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController icController =
      TextEditingController(); // Identity Card
  bool loading = true;
  int eventsJoined = 0;
  int luckyWins = 0;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final firestore = FirebaseFirestore.instance;

      // Load User Data
      final doc = await firestore.collection("users").doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        nameController.text = data["name"] ?? "";
        phoneController.text = data["phone"] ?? "";
        icController.text = data["ic_number"] ?? "";
      } else {
        // Fallback if doc doesn't exist yet but user is logged in
        nameController.text = user.displayName ?? "";
        // Extract name from email if displayName is null
        if (nameController.text.isEmpty && user.email != null) {
          nameController.text = user.email!.split("@")[0];
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error loading profile: $e")));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser!;
    if (nameController.text.isEmpty) return;

    setState(() => loading = true);
    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "name": nameController.text, // Name
      "phone": phoneController.text, // Phone
      "ic_number": icController.text, // IC
      "email": user.email,
    }, SetOptions(merge: true));

    setState(() => loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "No Email";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profile",
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),

            /// HEADER
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade100,
                        backgroundImage:
                            null, // Add image provider if available
                        child: Text(
                          nameController.text.isNotEmpty
                              ? nameController.text[0].toUpperCase()
                              : "U",
                          style: const TextStyle(
                            fontSize: 36,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showEditProfileDialog(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nameController.text.isEmpty ? "User" : nameController.text,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                  ),
                  if (phoneController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        phoneController.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// SETTINGS LIST
            _sectionHeader("Account Settings"),

            FutureBuilder<bool>(
              future: UserRoleService.isAdmin(),
              builder: (context, snapshot) {
                if (snapshot.data != true) return const SizedBox();
                return _profileItem(
                  icon: Icons.dashboard_outlined,
                  title: "Admin Dashboard",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminDashboardScreen(),
                      ),
                    );
                  },
                );
              },
            ),

            _profileItem(
              icon: Icons.person_outline,
              title: "Personal Details",
              onTap: () => _showEditProfileDialog(context),
            ),
            _profileItem(
              icon: Icons.notifications_none,
              title: "Notifications",
              onTap: () {},
            ),
            _profileItem(
              icon: Icons.lock_outline,
              title: "Privacy & Security",
              onTap: () {},
            ),

            const SizedBox(height: 24),

            _sectionHeader("Support"),
            _profileItem(
              icon: Icons.help_outline,
              title: "Help & Support",
              onTap: () {},
            ),
            _profileItem(
              icon: Icons.info_outline,
              title: "About App",
              trailing: const Text(
                "v1.0.0",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutAppScreen()),
                );
              },
            ),

            const SizedBox(height: 32),

            /// LOGOUT
            TextButton(
              onPressed: logout,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                "Log Out",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _profileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(icon, color: Colors.black, size: 26),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      trailing:
          trailing ??
          Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade300),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Edit Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Phone
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // IC Number
            TextField(
              controller: icController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "IC / ID Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  saveProfile();
                  Navigator.pop(context);
                },
                child: const Text("Save Changes"),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
