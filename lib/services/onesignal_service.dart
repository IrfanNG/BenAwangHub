import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OneSignalService {
  // Cloudflare proxy handles authentication server-side
  // No API keys needed in client code
  static const String _endpoint = 'https://onesignal-proxy.mnifanmohdariff.workers.dev/';

  static Future<void> sendNotification({
    required String title,
    required String content,
  }) async {
    final appId = dotenv.env['ONESIGNAL_APP_ID'] ?? '';

    if (appId.isEmpty) {
      debugPrint('OneSignal Error: App ID is missing from app.env');
      return;
    }

    debugPrint('OneSignal: Preparing to send notification...');

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          // No Authorization header needed — Cloudflare proxy adds it server-side
        },
        body: jsonEncode({
          'app_id': appId,
          'included_segments': ['Total Subscriptions'],
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
      }
    } catch (e) {
      debugPrint('OneSignal: Error during send: $e');
      // Don't rethrow — notification failure should not crash the app
    }
  }
}
