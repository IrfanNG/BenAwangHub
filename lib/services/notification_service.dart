import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final _collection = FirebaseFirestore.instance.collection(
    'notifications',
  );

  // Add a new notification
  static Future<void> addNotification({
    required String title,
    required String date,
    required String description,
  }) async {
    await _collection.add({
      'title': title,
      'date': date,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update an existing notification
  static Future<void> updateNotification({
    required String id,
    required String title,
    required String date,
    required String description,
  }) async {
    await _collection.doc(id).update({
      'title': title,
      'date': date,
      'description': description,
    });
  }

  // Delete a notification
  static Future<void> deleteNotification(String id) async {
    await _collection.doc(id).delete();
  }

  // Stream of notifications ordered by date
  static Stream<QuerySnapshot> getNotificationsStream() {
    return _collection.orderBy('date').snapshots();
  }
}
