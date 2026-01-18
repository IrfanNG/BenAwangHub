import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LuckyDrawService {
  static Future<void> pickWinners(String eventId, int winnerCount) async {
    final firestore = FirebaseFirestore.instance;

    // 1. Check if winners already picked
    final existing = await firestore
        .collection("events")
        .doc(eventId)
        .collection("winners")
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception("Winners already picked");
    }

    // 2. Get event
    final eventSnap =
        await firestore.collection("events").doc(eventId).get();

    final event = eventSnap.data()!;
    final int winnerCount = event["winnerCount"] ?? 1;

    final isFree =
        (event["adultFee"] ?? 0) == 0 && (event["childFee"] ?? 0) == 0;

    // 3. Get registrations with lucky number
    final regs = await firestore
        .collection("events")
        .doc(eventId)
        .collection("registrations")
        .where("luckyNumber", isNull: false)
        .get();

    if (regs.docs.isEmpty) {
      throw Exception("No eligible participants");
    }

    List<QueryDocumentSnapshot> eligible = regs.docs;

    // 4. Filter paid users if paid event
    if (!isFree) {
      final payments = await firestore
          .collection("payments")
          .where("eventId", isEqualTo: eventId)
          .where("status", isEqualTo: "approved")
          .get();

      final paidIds =
          payments.docs.map((e) => e["userId"]).toSet();

      eligible =
          eligible.where((r) => paidIds.contains(r.id)).toList();
    }

    if (eligible.length < winnerCount) {
      throw Exception("Not enough eligible participants");
    }

    // 5. Shuffle & pick
    eligible.shuffle(Random());

    final winners = eligible.take(winnerCount);

    // 6. Save winners
    for (final w in winners) {
      final data = w.data() as Map<String, dynamic>;

      await firestore
          .collection("events")
          .doc(eventId)
          .collection("winners")
          .doc(w.id)
          .set({
        "userId": w.id,
        "luckyNumber": data["luckyNumber"],
        "pickedAt": Timestamp.now(),
        "pickedBy": FirebaseAuth.instance.currentUser!.uid,
      });
    }
  }
}
