import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/repositories/i_device_token_repository.dart';
import 'package:siren_marketplace/core/services/firebase_messaging_service.dart';
import 'package:siren_marketplace/core/providers/router_provider.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/providers/offer_providers.dart';
import 'package:siren_marketplace/core/providers/order_providers.dart';
import 'package:siren_marketplace/core/providers/conversation_providers.dart';
import 'package:siren_marketplace/core/providers/catch_providers.dart';

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
      final repository = _ref.read(deviceTokenRepositoryProvider);

      if (enable) {
        // Request permission first
        final permissionGranted = await service.requestPermission();

        if (!permissionGranted) {
          debugPrint('Notification permission denied');
          _isRegistering = false;
          return false;
        }

        // Check if device is already registered
        final storedId = await service.getDeviceTokenId();
        bool isRegistered = false;

        if (storedId != null) {
          final checkResult = await repository.getDeviceToken(storedId);
          if (checkResult.isRight) {
            isRegistered = true;
          }
        }

        if (!isRegistered) {
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

          final result = await repository.registerDeviceToken(
            token: fcmToken,
            platform: platform,
            deviceId: deviceId,
          );

          final registrationSuccess = result.fold(
            ifLeft: (failure) {
              debugPrint('Failed to register device token: ${failure.message}');
              return false;
            },
            ifRight: (deviceToken) {
              debugPrint(
                'Device token registered successfully: ${deviceToken.id}',
              );
              service.saveDeviceTokenId(deviceToken.id);
              return true;
            },
          );

          if (!registrationSuccess) {
            _isRegistering = false;
            return false;
          }
        }

        // Use toggle endpoint to enable notifications
        final toggleResult = await repository.toggleNotifications(true);

        return toggleResult.fold(
          ifLeft: (failure) {
            debugPrint('Failed to enable notifications: ${failure.message}');
            return false;
          },
          ifRight: (success) async {
            if (success) {
              await service.setNotificationEnabled(true);
              state = true;

              // Set up token refresh listener if not already set
              service.onTokenRefresh((newToken) {
                _handleTokenRefresh(newToken);
              });
            }
            return success;
          },
        );
      } else {
        // Disable notifications via toggle endpoint
        final toggleResult = await repository.toggleNotifications(false);

        return toggleResult.fold(
          ifLeft: (failure) {
            debugPrint('Failed to disable notifications: ${failure.message}');
            return false;
          },
          ifRight: (success) async {
            if (success) {
              await service.setNotificationEnabled(false);
              // Do NOT clear device token ID so we can re-enable easily
              state = false;
            }
            return success;
          },
        );
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
  Future<void> initialize() async {
    final service = _ref.read(firebaseMessagingServiceProvider);

    // Initialize local notifications
    await service.initializeLocalNotifications();

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

    // Show local notification
    final service = _ref.read(firebaseMessagingServiceProvider);
    service.showLocalNotification(message);

    // Refresh data based on notification type
    _refreshData(message.data);
  }

  void _handleMessageOpened(RemoteMessage message) {
    debugPrint('Notification opened: ${message.notification?.title}');
    debugPrint('Message data: ${message.data}');

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

  void _refreshData(Map<String, dynamic> data) async {
    final type = data['type'] as String?;
    final userAsync = _ref.read(currentUserProvider);
    final user = userAsync.value;

    if (user == null) return;

    switch (type) {
      case 'offer':
      case 'new_offer':
      case 'offer_update':
        _ref.invalidate(fisherOffersProvider);
        _ref.invalidate(buyerOffersProvider);
        if (data.containsKey('product_id')) {
          _ref.invalidate(offersByProductProvider(data['product_id']));
        }
        break;
      case 'order':
      case 'new_order':
      case 'order_update':
        _ref.invalidate(fisherOrdersProvider);
        _ref.invalidate(fisherOrdersWithProductProvider);
        _ref.invalidate(buyerOrdersWithProductProvider);
        _ref.invalidate(myOrdersProvider);
        break;
      case 'message':
      case 'new_message':
        _ref.invalidate(userConversationsProvider(user.id));
        if (data.containsKey('conversation_id')) {
          // If we had a provider for messages in a conversation, we'd invalidate it here
          // e.g. _ref.invalidate(conversationMessagesProvider(data['conversation_id']));
        }
        break;
      case 'catch':
        _ref.invalidate(fisherCatchesProvider);
        break;
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) async {
    // Extract notification type and relevant ID from data
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    debugPrint('Notification navigation - type: $type, id: $id');

    final userAsync = await _ref.read(currentUserProvider.future);
    if (userAsync == null) return;

    final role = userAsync.currentRole;
    final rolePrefix = role == UserRole.fisher ? '/fisher' : '/buyer';
    final router = _ref.read(routerProvider);

    if (id == null) return;

    switch (type) {
      case 'message':
      case 'new_message':
        // Navigate to chat
        // Assuming id is conversationId. If it's userId, logic might differ.
        // Usually notifications send the conversation ID.
        router.push('$rolePrefix/chat/$id');
        break;
      case 'offer':
      case 'new_offer':
      case 'offer_update':
        // Navigate to offer details
        router.push('$rolePrefix/offer-details/$id');
        break;
      case 'order':
      case 'new_order':
      case 'order_update':
        // Navigate to order details
        router.push('$rolePrefix/order-details/$id');
        break;
      default:
        debugPrint('Unknown notification type for navigation: $type');
    }
  }
}

/// Provider to handle app initialization (e.g. notifications)
final appInitializationProvider = FutureProvider<void>((ref) async {
  await ref.read(notificationMessageHandlerProvider).initialize();
});
