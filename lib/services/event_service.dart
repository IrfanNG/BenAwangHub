import 'package:cloud_firestore/cloud_firestore.dart';
import 'onesignal_service.dart';

class EventService {
  static final _collection = FirebaseFirestore.instance.collection("events");

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
    await _collection.add({
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

    // Send Push Notification
    await OneSignalService.sendNotification(
      title: 'New Event: $title',
      content: 'Join us on $date at $location!',
    );
  }

  static Future<void> updateEvent({
    required String id,
    required String title,
    required String date,
    required String location,
    required double adultFee,
    required double childFee,
    required String deadline,
    required bool hasLuckyDraw,
    required List<String> families,
  }) async {
    await _collection.doc(id).update({
      "title": title,
      "date": date,
      "location": location,
      "adultFee": adultFee,
      "childFee": childFee,
      "deadline": deadline,
      "hasLuckyDraw": hasLuckyDraw,
      "families": families,
      "updatedAt": FieldValue.serverTimestamp(),
    });

    // Send Push Notification
    await OneSignalService.sendNotification(
      title: 'Event Update: $title',
      content: 'Details updated for the event on $date.',
    );
  }
}
