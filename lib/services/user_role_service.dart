import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRoleService {
  static Future<bool> isAdmin() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    var doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!doc.exists) return false;

    return doc["role"] == "admin";
  }
}
