import 'package:cloud_firestore/cloud_firestore.dart';

class EventService {
  static Future<void> createEvent({
    required String title,
    required String date,
    required String location,
    required double adultFee,
    required double childFee,
    required String deadline,
    required bool hasLuckyDraw,
    required List<String> families,
  }) async {
    await FirebaseFirestore.instance.collection("events").add({
      "title": title,
      "date": date,
      "location": location,
      "adultFee": adultFee,
      "childFee": childFee,
      "deadline": deadline,
      "hasLuckyDraw": hasLuckyDraw,
      "families": families,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
