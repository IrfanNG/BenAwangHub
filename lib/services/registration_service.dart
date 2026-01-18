import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationService {
  static String _generateLuckyNumber() {
    final rand = DateTime.now().millisecondsSinceEpoch % 900 + 100;
    return rand.toString(); // 100–999
  }

  static Future<void> register({
    required String eventId,
    required String userId,
    required int adults,
    required int kids,
    required double adultFee,
    required double childFee,
  }) async {
    /// 1️⃣ Get event data
    final eventDoc = await FirebaseFirestore.instance
        .collection("events")
        .doc(eventId)
        .get();

    final event = eventDoc.data()!;
    final hasLuckyDraw = event["hasLuckyDraw"] == true;

    final isFreeEvent =
        (event["adultFee"] ?? 0) == 0 && (event["childFee"] ?? 0) == 0;

    /// 2️⃣ Calculate total
    final double total = (adults * adultFee) + (kids * childFee);

    /// 3️⃣ Decide lucky number (FREE EVENT ONLY)
    String? luckyNumber;
    if (hasLuckyDraw && isFreeEvent) {
      luckyNumber = _generateLuckyNumber();
    }

    /// 4️⃣ Save registration
    await FirebaseFirestore.instance
        .collection("events")
        .doc(eventId)
        .collection("registrations")
        .doc(userId)
        .set({
      "adults": adults,
      "kids": kids,
      "total": total,
      "status": "registered",
      "luckyNumber": luckyNumber, // null if not applicable
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
