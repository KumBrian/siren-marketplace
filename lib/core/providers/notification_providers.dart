import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/repositories/i_device_token_repository.dart';
import 'package:siren_marketplace/core/services/firebase_messaging_service.dart';

/// Provider for notification settings (toggle state)
/// This now persists to SharedPreferences via FirebaseMessagingService
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, bool>((ref) {
      return NotificationSettingsNotifier(ref);
    });

/// Provider for accessing the FirebaseMessagingService
final firebaseMessagingServiceProvider = Provider<FirebaseMessagingService>((
  ref,
) {
  return sl<FirebaseMessagingService>();
});

/// Provider for the device token repository
final deviceTokenRepositoryProvider = Provider<IDeviceTokenRepository>((ref) {
  return sl<IDeviceTokenRepository>();
});

/// Notifier for managing notification settings state
class NotificationSettingsNotifier extends StateNotifier<bool> {
  final Ref _ref;
  bool _isRegistering = false;

  NotificationSettingsNotifier(this._ref) : super(false) {
    // Load saved state on initialization
    _loadSavedState();
  }

  /// Load the saved notification state from SharedPreferences
  Future<void> _loadSavedState() async {
    try {
      final service = _ref.read(firebaseMessagingServiceProvider);
      final enabled = await service.isNotificationEnabled();
      state = enabled;
    } catch (e) {
      debugPrint('Error loading notification state: $e');
    }
  }

  /// Toggle notifications on/off
  /// Handles permission request and device token registration
  Future<bool> toggleNotifications(bool enable) async {
    if (_isRegistering) return state;
    _isRegistering = true;

    try {
      final service = _ref.read(firebaseMessagingServiceProvider);

      if (enable) {
        // Request permission first
        final permissionGranted = await service.requestPermission();

        if (!permissionGranted) {
          debugPrint('Notification permission denied');
          _isRegistering = false;
          return false;
        }

        // Get FCM token and register with backend
        final fcmToken = await service.getToken();
        if (fcmToken == null) {
          debugPrint('Failed to get FCM token');
          _isRegistering = false;
          return false;
        }

        // Register device token with backend
        final deviceId = await service.getDeviceId();
        final platform = service.getPlatform();

        final repository = _ref.read(deviceTokenRepositoryProvider);
        final result = await repository.registerDeviceToken(
          token: fcmToken,
          platform: platform,
          deviceId: deviceId,
        );

        result.fold(
          ifLeft: (failure) {
            debugPrint('Failed to register device token: ${failure.message}');
          },
          ifRight: (deviceToken) {
            debugPrint(
              'Device token registered successfully: ${deviceToken.id}',
            );
            service.saveDeviceTokenId(deviceToken.id);
          },
        );

        // Save enabled state
        await service.setNotificationEnabled(true);
        state = true;

        // Set up token refresh listener
        service.onTokenRefresh((newToken) {
          _handleTokenRefresh(newToken);
        });

        return true;
      } else {
        // Disable notifications
        await service.setNotificationEnabled(false);
        await service.clearDeviceTokenId();
        state = false;
        return true;
      }
    } catch (e) {
      debugPrint('Error toggling notifications: $e');
      return false;
    } finally {
      _isRegistering = false;
    }
  }

  /// Handle FCM token refresh
  Future<void> _handleTokenRefresh(String newToken) async {
    if (!state) return; // Only re-register if notifications are enabled

    try {
      final service = _ref.read(firebaseMessagingServiceProvider);
      final repository = _ref.read(deviceTokenRepositoryProvider);

      final deviceId = await service.getDeviceId();
      final platform = service.getPlatform();

      final result = await repository.registerDeviceToken(
        token: newToken,
        platform: platform,
        deviceId: deviceId,
      );

      result.fold(
        ifLeft: (failure) {
          debugPrint('Failed to register refreshed token: ${failure.message}');
        },
        ifRight: (deviceToken) {
          debugPrint('Refreshed token registered: ${deviceToken.id}');
          service.saveDeviceTokenId(deviceToken.id);
        },
      );
    } catch (e) {
      debugPrint('Error handling token refresh: $e');
    }
  }

  /// Check if notifications are authorized at the system level
  Future<bool> isAuthorized() async {
    final service = _ref.read(firebaseMessagingServiceProvider);
    return await service.isAuthorized();
  }

  /// Send a test notification
  Future<bool> sendTestNotification() async {
    try {
      final repository = _ref.read(deviceTokenRepositoryProvider);
      final result = await repository.sendTestNotification(
        title: 'Test Notification',
        body: 'This is a test push notification sent to your device',
        data: {'custom_key': 'custom_value'},
      );

      return result.fold(
        ifLeft: (failure) {
          debugPrint('Failed to send test notification: ${failure.message}');
          return false;
        },
        ifRight: (success) => success,
      );
    } catch (e) {
      debugPrint('Error sending test notification: $e');
      return false;
    }
  }
}

/// Provider for handling notification messages
final notificationMessageHandlerProvider = Provider<NotificationMessageHandler>(
  (ref) {
    return NotificationMessageHandler(ref);
  },
);

/// Handler for processing incoming push notifications
class NotificationMessageHandler {
  final Ref _ref;

  NotificationMessageHandler(this._ref);

  /// Initialize notification handlers
  void initialize() {
    final service = _ref.read(firebaseMessagingServiceProvider);

    // Handle foreground messages
    service.setupForegroundMessageHandler(_handleForegroundMessage);

    // Handle notification taps when app is in background
    service.setupMessageOpenedHandler(_handleMessageOpened);

    // Check if app was opened from a notification
    _checkInitialMessage();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.notification?.title}');
    debugPrint('Message data: ${message.data}');

    // TODO: Show local notification or update UI
    // For now, just log the message
  }

  void _handleMessageOpened(RemoteMessage message) {
    debugPrint('Notification opened: ${message.notification?.title}');
    debugPrint('Message data: ${message.data}');

    // TODO: Navigate to appropriate screen based on message data
    // e.g., if it's a chat message, navigate to ChatPage
    // if it's an offer update, navigate to OfferDetailsScreen
    _handleNotificationNavigation(message.data);
  }

  Future<void> _checkInitialMessage() async {
    final service = _ref.read(firebaseMessagingServiceProvider);
    final initialMessage = await service.getInitialMessage();

    if (initialMessage != null) {
      debugPrint(
        'App opened from notification: ${initialMessage.notification?.title}',
      );
      _handleNotificationNavigation(initialMessage.data);
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Extract notification type and relevant ID from data
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    debugPrint('Notification navigation - type: $type, id: $id');

    // TODO: Implement navigation based on notification type
    // This would typically use GoRouter or similar
    // switch (type) {
    //   case 'message':
    //     // Navigate to chat
    //     break;
    //   case 'offer':
    //     // Navigate to offer details
    //     break;
    //   case 'order':
    //     // Navigate to order details
    //     break;
    // }
  }
}
