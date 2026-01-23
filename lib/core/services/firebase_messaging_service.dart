import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing Firebase Cloud Messaging (FCM) interactions
class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const String _notificationEnabledKey = 'push_notifications_enabled';
  static const String _deviceTokenIdKey = 'device_token_id';

  /// Get the current FCM token
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Request notification permissions from the user
  /// Returns true if permission was granted
  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      debugPrint('Notification permission granted: $granted');
      return granted;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Check if notifications are currently authorized
  Future<bool> isAuthorized() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('Error checking notification authorization: $e');
      return false;
    }
  }

  /// Get the current platform string for API
  String getPlatform() {
    if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isAndroid) {
      return 'android';
    }
    return 'unknown';
  }

  /// Get a unique device identifier
  /// Uses a combination of platform-specific identifiers
  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_unique_id');

    if (deviceId == null) {
      // Generate a unique ID for this device installation
      deviceId =
          '${getPlatform()}_${DateTime.now().millisecondsSinceEpoch}_${identityHashCode(this)}';
      await prefs.setString('device_unique_id', deviceId);
    }

    return deviceId;
  }

  /// Save the notification enabled state locally
  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);
  }

  /// Get the saved notification enabled state
  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? false;
  }

  /// Save the registered device token ID from backend
  Future<void> saveDeviceTokenId(int tokenId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_deviceTokenIdKey, tokenId);
  }

  /// Get the saved device token ID
  Future<int?> getDeviceTokenId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_deviceTokenIdKey);
  }

  /// Clear the saved device token ID
  Future<void> clearDeviceTokenId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceTokenIdKey);
  }

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize local notifications
  Future<void> initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Local notification clicked: ${response.payload}');
        // We can handle local notification taps here if needing specific logic
        // For now, main logic is via FCM handlers
      },
    );

    // Create high importance channel for Android
    if (Platform.isAndroid) {
      await _createAndroidChannel();
    }
  }

  Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Show a local notification
  Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            icon: android.smallIcon,
            priority: Priority.high,
            importance: Importance.max,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// Set up foreground message handler
  void setupForegroundMessageHandler(
    void Function(RemoteMessage message) onMessage,
  ) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  /// Set up background message opened handler (when user taps notification)
  void setupMessageOpenedHandler(
    void Function(RemoteMessage message) onMessageOpened,
  ) {
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpened);
  }

  /// Check if the app was opened from a notification
  Future<RemoteMessage?> getInitialMessage() async {
    return await _messaging.getInitialMessage();
  }

  /// Subscribe to a topic for targeted notifications
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  /// Delete the FCM token (useful when user logs out)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }

  /// Listen for token refresh events
  void onTokenRefresh(void Function(String token) callback) {
    _messaging.onTokenRefresh.listen(callback);
  }
}
