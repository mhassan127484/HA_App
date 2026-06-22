import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background FCM message: ${message.messageId}');
}

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions (iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configure foreground notifications
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground FCM: ${message.notification?.title}');
    });

    // Handle notification tap from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Opened from background: ${message.data}');
    });
  }

  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('FCM token error: $e');
      return null;
    }
  }
}
