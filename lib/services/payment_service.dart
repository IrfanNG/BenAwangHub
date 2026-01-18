import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  static String _generateLuckyNumber() {
    final rand = DateTime.now().millisecondsSinceEpoch % 900 + 100;
    return rand.toString(); // 100–999
  }

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
    final eventSnap =
        await firestore.collection("events").doc(eventId).get();

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

    /// 5️⃣ Assign lucky number if not exists
    if (reg["luckyNumber"] == null) {
      await regRef.update({
        "luckyNumber": _generateLuckyNumber(),
      });
    }
  }
}
