import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QrScanScreen extends StatelessWidget {
  const QrScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Check-In QR")),
      body: MobileScanner(
        onDetect: (capture) async {
          final raw = capture.barcodes.first.rawValue;
          if (raw == null) return;

          final eventId = raw.trim();
          final userId = FirebaseAuth.instance.currentUser!.uid;

          final docId = "${eventId}_$userId";
          final ref = FirebaseFirestore.instance
              .collection("attendance")
              .doc(docId);

          final snap = await ref.get();

          await FirebaseFirestore.instance
              .collection("attendance")
              .doc("${eventId}_${userId}")
              .set({
            "eventId": eventId,
            "userId": userId,
            "checkInAt": FieldValue.serverTimestamp(),
          });

          // 🚫 BLOCK DUPLICATE
          if (snap.exists) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("You are already checked in")),
            );
            Navigator.pop(context);
            return;
          }

          // ✅ RECORD ATTENDANCE
          await ref.set({
            "eventId": eventId,
            "userId": userId,
            "checkedInAt": FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Check-in successful")),
          );

          Navigator.pop(context);
        },
      ),
    );
  }
}
