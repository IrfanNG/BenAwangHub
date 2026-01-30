import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationService {
  static List<String> _generateLuckyNumbers(int count) {
    final List<String> numbers = [];
    final random = DateTime.now().millisecondsSinceEpoch;

    // Simple generation. In production, check explicitly for collisions in DB.
    // For this small app, we just generate 'count' numbers.
    for (var i = 0; i < count; i++) {
      // Offset random slightly to ensure difference in tight loop
      final val = (random + (i * 12345)) % 900 + 100;
      numbers.add(val.toString());
    }
    return numbers;
  }

  static Future<void> register({
    required String eventId,
    required String userId,
    required int adults,
    required int kids,
    required double adultFee,
    required double childFee,
<<<<<<< HEAD
    required String? familyName,
=======
>>>>>>> a9715c3b08abbe02e217ceee16cfbb2ddd07cbb1
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
    final int totalPax = adults + kids;

    /// 3️⃣ Decide lucky numbers (FREE EVENT ONLY)
    List<String> luckyNumbers = [];
    if (hasLuckyDraw && isFreeEvent) {
      luckyNumbers = _generateLuckyNumbers(totalPax);
    }

    /// 4️⃣ Save registration
<<<<<<< HEAD
    String status = "registered";
    if (!isFreeEvent) {
      status = "pending_payment";
    }

=======
>>>>>>> a9715c3b08abbe02e217ceee16cfbb2ddd07cbb1
    await FirebaseFirestore.instance
        .collection("events")
        .doc(eventId)
        .collection("registrations")
        .doc(userId)
        .set({
          "adults": adults,
          "kids": kids,
          "total": total,
<<<<<<< HEAD
          "status": status,
          "familyName": familyName,
=======
          "status": "registered",
>>>>>>> a9715c3b08abbe02e217ceee16cfbb2ddd07cbb1
          "luckyNumbers": luckyNumbers, // List of strings
          "createdAt": FieldValue.serverTimestamp(),
        });
  }
}
