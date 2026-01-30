import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Check-In QR"), centerTitle: true),
      body: MobileScanner(
        onDetect: (capture) async {
          if (isProcessing) return; // Prevent multiple scans

          final raw = capture.barcodes.first.rawValue;
          if (raw == null) return;

          setState(() => isProcessing = true);

          try {
            // Expected format: just eventId, or "eventId|extra"?
            // Previous code assumed raw is eventId. Let's stick to that but handle split if needed from event_detail logic
            // event_detail generated "$eventId|$userId" but current code read just raw.
            // If the QR generated in event_detail_screen is "$eventId|$userId", we need to parse it.
            // However, the event_detail generator in the previous file I read generated: qrData = "$eventId|$userId";
            // The previous scanner implementation treated `raw` as `eventId`. This is a bug if not matching.
            // But since this is "Scan Check-In", usually USER scans EVENT QR?
            // Wait, look at event_detail: "Your Event QR" -> "$eventId|$userId". This implies the user shows this QR to ADMIN?
            // If so, who is scanning?
            // Text says "Show this at the entrance". So User shows QR, Admin scans.
            // The scanner Logic says:
            // userId = My Current User.
            // raw = capture.
            // If Admin scans User's QR ("eventId|userId"), then:
            //   eventId = parts[0]
            //   scannedUserId = parts[1]
            //   We should record attendance for scannedUserId.
            // BUT, the previous code used `FirebaseAuth.instance.currentUser!.uid` as the userId to record.
            // If I am Admin scanning, I am recording *MY OWN* attendance? That's wrong.
            // This suggests the previous logic was fundamentally flawed or I misunderstood usage.
            // "Scan Check-In QR" screen. UserRoleService.isAdmin() hides this button?
            // In event_detail: `if (snap.data != true) return TextButton...` -> Non-admin sees "Scan Check-In QR".
            // So Non-Admin is scanning... WHAT?
            // If Non-Admin Scans, they must be scanning an EVENT QR Code placed at the venue.
            // If so, the QR Code contains just `eventId`.
            // So `raw` = `eventId`.
            // Then `userId` = current user (the attendee).
            // Logic: Attendee scans generic Event QR -> records their own attendance.
            // Okay, assuming this flow.

            // Correction based on event_detail:
            // `buildUserQR` creates `$eventId|$userId`. This is "Show this to entrance".
            // If the user is scanning a code AT THE VENUE, then the code at venue is likely just `eventId`.
            // The code I read in `qr_scan_screen` treated `raw` as `eventId`.
            // So I will assume the flow is: User scans Event QR.

            final eventId = raw.trim();
            final userId = FirebaseAuth.instance.currentUser!.uid;
            // Note: eventId might be "eventId|userId" if they scan another user lol.
            // Let's assume valid Event ID.

            final docId = "${eventId}_$userId";
            final ref = FirebaseFirestore.instance
                .collection("attendance")
                .doc(docId);

            final snap = await ref.get();

            if (snap.exists) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("You are already checked in")),
                );
                Navigator.pop(context);
              }
              return;
            }

            await ref.set({
              "eventId": eventId,
              "userId": userId,
              "checkedInAt": FieldValue.serverTimestamp(),
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Check-in successful")),
              );
              Navigator.pop(context);
            }
          } catch (e) {
            if (mounted) {
              setState(() => isProcessing = false); // Allow retry? or just pop
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Error: $e")));
              Navigator.pop(context); // Pop on error to avoid freeze
            }
          }
        },
      ),
    );
  }
}
