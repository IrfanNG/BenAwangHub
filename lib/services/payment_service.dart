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
      "createdAt": Timestamp.now(),
    });
  }

  static Future<void> approvePayment(String paymentId) async {
    await FirebaseFirestore.instance
        .collection("payments")
        .doc(paymentId)
        .update({
      "status": "approved",
      "verifiedAt": Timestamp.now(),
    });
  }
}
