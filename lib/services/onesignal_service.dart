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
    final apiKey = dotenv.get('ONESIGNAL_REST_API_KEY', fallback: '');

    if (apiKey.isEmpty) {
      debugPrint('OneSignal Error: REST API Key is missing from .env/app.env');
      return;
    }

    debugPrint('OneSignal: Preparing to send notification...');
    debugPrint('OneSignal: App ID - $appId');

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $apiKey',
        },
        body: jsonEncode({
          'app_id': appId,
          'included_segments': ['Subscribed Users'], 
          'headings': {'en': title},
          'contents': {'en': content},
        }),
      );

      debugPrint('OneSignal: Response Status - ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final resData = jsonDecode(response.body);
        debugPrint('OneSignal: Success! ID - ${resData['id']}');
      } else {
        debugPrint('OneSignal API Error: ${response.body}');
        // On Web, if this is a CORS error, status code might be 0 or throw
        throw Exception('OneSignal API Error: ${response.body}');
      }
    } catch (e) {
      debugPrint('OneSignal: Critical error during send: $e');
      // If it's a CORS error, warn the user
      if (e.toString().contains('XMLHttpRequest')) {
        debugPrint('OneSignal: This looks like a CORS error. OneSignal REST API often blocks direct browser calls.');
      }
      rethrow;
    }
  }
}
