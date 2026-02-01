import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with Email and Password
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      // Verify user exists in Firestore
      final userDoc = await _firestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();
      if (!userDoc.exists) {
        // If they auth'd but don't have a doc (edge case), create one or sign out
        // For now, let's treat it as an error to match previous logic,
        // or we could auto-create. The previous logic threw an exception.
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: "This email is not registered in the system",
        );
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign Up with Email and Password
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _createUserInFirestore(userCredential.user!, name: name);
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper: Create User in Firestore (for Email Sign Up)
  Future<void> _createUserInFirestore(User user, {required String name}) async {
    await _firestore.collection("users").doc(user.uid).set({
      "email": user.email,
      "name": name,
      "role": "user",
      "createdAt": FieldValue.serverTimestamp(),
      "authMethod": "email",
    });
  }
}
