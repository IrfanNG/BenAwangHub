import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  static Future<void> submitPayment({
    required String eventId,
    required String userId,
    required double amount,
  }) async {
    await FirebaseFirestore.instance.collection("payments").add({
      "eventId": eventId,
      "userId": userId,
      "amount": amount,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  static List<String> _generateLuckyNumbers(int count) {
    final List<String> numbers = [];
    final random = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0; i < count; i++) {
      final val = (random + (i * 12345)) % 900 + 100;
      numbers.add(val.toString());
    }
    return numbers;
  }

  static Future<void> approvePayment(String paymentId) async {
    final firestore = FirebaseFirestore.instance;

    /// 1️⃣ Get payment
    final paymentRef = firestore.collection("payments").doc(paymentId);
    final paymentSnap = await paymentRef.get();

    if (!paymentSnap.exists) return;

    final payment = paymentSnap.data()!;
    final String eventId = payment["eventId"];
    final String userId = payment["userId"];

    /// 2️⃣ Approve payment
    await paymentRef.update({
      "status": "approved",
      "verifiedAt": FieldValue.serverTimestamp(),
    });

    /// 3️⃣ Get event
    final eventSnap = await firestore.collection("events").doc(eventId).get();

    if (!eventSnap.exists) return;

    final event = eventSnap.data()!;
    final bool hasLuckyDraw = event["hasLuckyDraw"] == true;

    if (!hasLuckyDraw) return;

    /// 4️⃣ Get registration
    final regRef = firestore
        .collection("events")
        .doc(eventId)
        .collection("registrations")
        .doc(userId);

    final regSnap = await regRef.get();
    if (!regSnap.exists) return;

    final reg = regSnap.data()!;

    // Check if lucky numbers already assigned
    final exitingNumbers = reg["luckyNumbers"];
    if (exitingNumbers != null && (exitingNumbers as List).isNotEmpty) return;

    /// 5️⃣ Assign lucky numbers
    final int adults = reg["adults"] ?? 0;
    final int kids = reg["kids"] ?? 0;
    final int totalPax = adults + kids;

    if (totalPax > 0) {
      await regRef.update({"luckyNumbers": _generateLuckyNumbers(totalPax)});
    }
  }
}
