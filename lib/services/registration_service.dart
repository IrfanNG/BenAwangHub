import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationService {
  static Future<void> register({
    required String eventId,
    required String userId,
    required int adults,
    required int kids,
    required double adultFee,
    required double childFee,
  }) async {
    double total = (adults * adultFee) + (kids * childFee);

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
      "createdAt": Timestamp.now(),
    });
  }
}
