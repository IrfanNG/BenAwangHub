import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class OneSignalService {
  static const String _endpoint = 'https://onesignal.com/api/v1/notifications';

  static Future<void> sendNotification({
    required String title,
    required String content,
  }) async {
    final appId = dotenv.get('ONESIGNAL_APP_ID', fallback: 'ebfffbc8-21f0-4f90-bb39-53f62672b18d');
    final apiKey = dotenv.get('ONESIGNAL_REST_API_KEY');

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $apiKey',
        },
        body: jsonEncode({
          'app_id': appId,
          'included_segments': ['All'],
          'headings': {'en': title},
          'contents': {'en': content},
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('OneSignal Error: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending OneSignal notification: $e');
    }
  }
}
