import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser!;
    final doc =
        await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

    if (doc.exists) {
      nameController.text = doc["name"] ?? "";
    }

    setState(() => loading = false);
  }

  Future<void> saveName() async {
    final user = FirebaseAuth.instance.currentUser!;

    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "name": nameController.text,
      "email": user.email,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8FAFC);
    const primary = Color(0xFF111827);
    const secondary = Color(0xFF6B7280);
    const border = Color(0xFFE5E7EB);
    const danger = Color(0xFFDC2626);

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: primary,
        elevation: 0,
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// ===== AVATAR =====
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: const Icon(
                Icons.person,
                size: 56,
                color: secondary,
              ),
            ),

            const SizedBox(height: 24),

            /// ===== NAME FIELD =====
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              child: TextField(
                controller: nameController,
                style: const TextStyle(
                  fontSize: 16,
                  color: primary,
                ),
                decoration: const InputDecoration(
                  labelText: "Your Name",
                  labelStyle: TextStyle(color: secondary),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ===== SAVE BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: saveName,
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 32),

            /// ===== LOGOUT =====
            TextButton.icon(
              onPressed: logout,
              icon: const Icon(Icons.logout, color: danger),
              label: const Text(
                "Logout",
                style: TextStyle(
                  color: danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
