import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class OneSignalService {
  // Using Cloudflare proxy to bypass Web CORS restrictions
  static const String _endpoint = 'https://onesignal-proxy.mnifanmohdariff.workers.dev/';

  static Future<void> sendNotification({
    required String title,
    required String content,
  }) async {
    const appId = 'ebfffbc8-21f0-4f90-bb39-53f62672b18d';
    const apiKey = 'os_v2_app_5p77xsbb6bhzbozzkp3cm4vrru6jdqcbkn3uda4rynjeexekg23kf4ti4aaeaizxprtkrhlzb6et5m6nttbuxzlmdtb42asidn2oyua';

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
        // On Web, if this is a CORS error, status code might be 0 or throw
        throw Exception('OneSignal API Error: ${response.body}');
      }
    } catch (e) {
      debugPrint('OneSignal: Critical error during send: $e');
      if (e.toString().contains('XMLHttpRequest') || kIsWeb) {
        debugPrint('OneSignal: This is likely a CORS error. OneSignal REST API blocks direct browser calls on Web.');
      }
      // We removed 'rethrow' so that sending a push notification failure 
      // does not crash the app (like stopping an event from being created).
    }
  }
}
