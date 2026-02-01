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
    required String? familyName,
  }) async {
    // Check if user is admin
    final checks = await Future.wait([
      FirebaseFirestore.instance.collection("users").doc(userId).get(),
    ]);

    final userDoc = checks[0];
    if (userDoc.exists && userDoc["role"] == "admin") {
      throw "Admins cannot register for events. Use the admin dashboard to manage events.";
    }

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
    String status = "registered";
    if (!isFreeEvent) {
      status = "pending_payment";
    }

    await FirebaseFirestore.instance
        .collection("events")
        .doc(eventId)
        .collection("registrations")
        .doc(userId)
        .set({
          "adults": adults,
          "kids": kids,
          "total": total,
          "status": status,
          "familyName": familyName,
          "luckyNumbers": luckyNumbers, // List of strings
          "createdAt": FieldValue.serverTimestamp(),
        });
  }
}
