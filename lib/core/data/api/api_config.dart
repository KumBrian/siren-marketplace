import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API configuration class that reads from environment variables
class ApiConfig {
  /// Base URL for the Core API (authentication, user accounts)
  static String get coreBaseUrl =>
      dotenv.env['API_CORE_BASE_URL'] ??
      'https://api.core.dev.siren.dhi-cm.com/api/v1';

  /// Base URL for the Marketplace API (catches, offers, orders, etc.)
  static String get marketplaceBaseUrl =>
      dotenv.env['API_MARKETPLACE_BASE_URL'] ??
      'https://api.marketplace.dev.siren.dhi-cm.com/api/v1';

  /// Email for authentication
  static String get email => dotenv.env['API_EMAIL'] ?? '';

  /// Password for authentication
  static String get password => dotenv.env['API_PASSWORD'] ?? '';

  /// Whether to use API data source
  static bool get useApiDataSource =>
      dotenv.env['USE_API_DATA_SOURCE']?.toLowerCase() == 'true';

  /// Whether offline mode is enabled
  static bool get enableOfflineMode =>
      dotenv.env['ENABLE_OFFLINE_MODE']?.toLowerCase() == 'true';

  // Core API Endpoints (authentication, user management)
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String authenticate = '/auth/authenticate';
  static const String tokenRefresh = '/token/refresh';

  // Account endpoints (if needed)
  static const String myProfile = '/accounts/my-profile';
  static const String updateProfile = '/accounts/update-profile';
  static const String accountsList = '/accounts/list';
  static const String toggleNotifications = '/accounts/toggle-notifications';

  // Marketplace API Endpoints
  static const String fishCatches = '/fish_catches';
  static const String myFishCatches = '/fish-catches/my-fish-catches';
  static const String offers = '/offers';
  static const String receivedOffers = '/offers/received-offers';
  static const String myOffers = '/offers/my-offers';
  static const String saleOrders = '/sale_orders';
  static const String saleOrdersCreate = '/sale-orders/create';
  static const String mySaleOrders = '/sale-orders/my-orders';
  static const String messages = '/messages';
  static const String reviews = '/reviews';
  static const String products = '/products';
  static const String markets = '/markets';
  static const String species = '/species';
  static const String gears = '/gears';

  /// Get endpoint for specific fish catch
  static String fishCatch(String id) => '$fishCatches/$id';

  /// Get endpoint for specific offer
  static String offer(String id) => '$offers/$id';

  /// Get endpoint for specific sale order
  static String saleOrder(String id) => '$saleOrders/$id';

  /// Get endpoint for specific message
  static String message(String id) => '$messages/$id';

  /// Get endpoint for specific review
  static String review(String id) => '$reviews/$id';

  /// Get endpoint for specific account
  static String account(String id) => '/accounts/$id';
}
