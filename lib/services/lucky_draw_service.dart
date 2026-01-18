import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LuckyDrawService {
  /// Returns list of {userId, number} for animation
  static Future<List<Map<String, String>>> getEligibleTickets(
    String eventId,
  ) async {
    final firestore = FirebaseFirestore.instance;

    // 1. Get existing winners to exclude them?
    final existingSnap = await firestore
        .collection("events")
        .doc(eventId)
        .collection("winners")
        .get();

    final existingWinnerNumbers = existingSnap.docs.map((d) => d.id).toSet();

    // 2. Get event
    final eventSnap = await firestore.collection("events").doc(eventId).get();
    final event = eventSnap.data()!;
    final isFree =
        (event["adultFee"] ?? 0) == 0 && (event["childFee"] ?? 0) == 0;

    // 3. Get registrations
    final regs = await firestore
        .collection("events")
        .doc(eventId)
        .collection("registrations")
        .get();

    if (regs.docs.isEmpty) return [];

    List<Map<String, String>> tickets = [];

    for (var doc in regs.docs) {
      final data = doc.data();
      final String userId = doc.id;

      if (data["luckyNumbers"] != null) {
        final List<dynamic> nums = data["luckyNumbers"];
        for (var n in nums) {
          if (!existingWinnerNumbers.contains(n.toString())) {
            tickets.add({"userId": userId, "number": n.toString()});
          }
        }
      } else if (data["luckyNumber"] != null) {
        final n = data["luckyNumber"].toString();
        if (!existingWinnerNumbers.contains(n)) {
          tickets.add({"userId": userId, "number": n});
        }
      }
    }

    if (!isFree) {
      final payments = await firestore
          .collection("payments")
          .where("eventId", isEqualTo: eventId)
          .where("status", isEqualTo: "approved")
          .get();

      final paidIds = payments.docs.map((e) => e["userId"]).toSet();
      tickets = tickets.where((t) => paidIds.contains(t["userId"])).toList();
    }

    return tickets;
  }

  static Future<void> saveWinner(
    String eventId,
    Map<String, String> ticket,
  ) async {
    await FirebaseFirestore.instance
        .collection("events")
        .doc(eventId)
        .collection("winners")
        .doc(ticket["number"])
        .set({
          "userId": ticket["userId"],
          "luckyNumber": ticket["number"],
          "pickedAt": Timestamp.now(),
          "pickedBy": FirebaseAuth.instance.currentUser!.uid,
        });
  }

  static Future<void> pickWinners(String eventId, int winnerCount) async {
    final tickets = await getEligibleTickets(eventId);

    if (tickets.isEmpty) throw Exception("No eligible tickets");
    if (tickets.length < winnerCount) throw Exception("Not enough tickets");

    tickets.shuffle(Random());
    final winners = tickets.take(winnerCount);

    for (final w in winners) {
      await saveWinner(eventId, w);
    }
  }
}
