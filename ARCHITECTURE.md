# Siren Marketplace - Architecture Documentation

> A comprehensive technical documentation of the Siren Marketplace Flutter application architecture.

---

## Table of Contents

1. [Overview](#overview)
2. [Project Structure](#project-structure)
3. [Architecture Pattern](#architecture-pattern)
4. [Dependency Injection](#dependency-injection)
5. [State Management](#state-management)
6. [Navigation](#navigation)
7. [Data Layer](#data-layer)
8. [Local Storage & Database](#local-storage--database)
9. [API Integration](#api-integration)
10. [Caching Strategy](#caching-strategy)
11. [Offline Support](#offline-support)
12. [Authentication](#authentication)
13. [Push Notifications](#push-notifications)
14. [Key Technologies](#key-technologies)

---

## Overview

Siren Marketplace is a Flutter-based mobile application that connects fishers with buyers in a seafood marketplace. The app supports dual user roles (Fisher/Buyer), enabling product listing, offer negotiations, order management, messaging, and reviews.

### Key Features

- **Multi-role support**: Users can switch between Fisher and Buyer roles
- **Offline-first architecture**: Full functionality even without network connectivity
- **Real-time pricing negotiations**: Offer and counter-offer system
- **Push notifications**: Firebase Cloud Messaging integration
- **Comprehensive caching**: Local database mirrors remote data

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── constants/                   # App-wide constants
├── core/                        # Shared core functionality
│   ├── config/                  # App configuration (API mode switching)
│   ├── constants/               # Colors, dimensions, strings
│   ├── data/                    # Data layer implementation
│   │   ├── api/                 # API client, interceptors, models
│   │   ├── database/            # SQLite database helper
│   │   ├── datasources/         # Data source implementations
│   │   │   ├── api/             # Remote API data sources
│   │   │   ├── local/           # Local SQLite data sources
│   │   │   ├── demo/            # In-memory demo data sources
│   │   │   └── interfaces/      # Data source contracts
│   │   ├── mappers/             # Entity ↔ Model mappers
│   │   ├── models/              # Data models (persistence layer)
│   │   ├── repositories/        # Repository implementations
│   │   ├── storage/             # Secure token storage
│   │   └── services/            # Data services (seeding, etc.)
│   ├── di/                      # Dependency injection setup
│   ├── domain/                  # Domain layer (business logic)
│   │   ├── entities/            # Business entities
│   │   ├── enums/               # Domain enums
│   │   ├── exceptions/          # Custom exceptions
│   │   ├── repositories/        # Repository interfaces
│   │   ├── services/            # Domain services
│   │   └── value_objects/       # Value objects (Price, Weight, etc.)
│   ├── network/                 # Network utilities
│   ├── providers/               # Riverpod providers
│   ├── services/                # Core services (connectivity, FCM)
│   ├── utils/                   # Utility functions
│   └── widgets/                 # Shared UI widgets
├── data/                        # Legacy/shared data
└── features/                    # Feature modules
    ├── auth/                    # Authentication
    ├── buyer/                   # Buyer-specific screens
    ├── chat/                    # Messaging feature
    ├── fisher/                  # Fisher-specific screens
    ├── shared/                  # Shared feature components
    └── user/                    # User profile & settings
```

---

## Architecture Pattern

### Clean Architecture

The application follows **Clean Architecture** principles with clear separation of concerns across three main layers:

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION                          │
│  (Screens, Widgets, Providers)                          │
├─────────────────────────────────────────────────────────┤
│                      DOMAIN                              │
│  (Entities, Repositories Interfaces, Services, VOs)     │
├─────────────────────────────────────────────────────────┤
│                       DATA                               │
│  (Repository Impl, Data Sources, Mappers, Models, API)  │
└─────────────────────────────────────────────────────────┘
```

#### Domain Layer (`lib/core/domain/`)

- **Entities**: Pure Dart classes representing business objects (`User`, `Product`, `Offer`, `Order`, `Catch`, `Review`, `Message`, `Conversation`)
- **Value Objects**: Immutable objects encapsulating domain concepts (`Price`, `Weight`, `PricePerKg`, `Rating`, `OfferTerms`)
- **Repository Interfaces**: Contracts defining data operations
- **Services**: Domain services orchestrating business logic (`SessionService`, `NegotiationService`, `OrderService`, `RatingService`, `MarketplaceService`, `MessageService`)

#### Data Layer (`lib/core/data/`)

- **Repository Implementations**: Concrete implementations coordinating data sources
- **Data Sources**: Abstracting data access (API, Local SQLite, Demo)
- **Models**: Data transfer objects for persistence/API
- **Mappers**: Transform between domain entities and data models
- **API Client**: HTTP client with interceptors

#### Presentation Layer (`lib/features/*/presentation/`)

- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components
- **Providers**: Riverpod state providers

### Repository Pattern

Each domain concept has a repository interface and implementation:

```dart
// Interface (Domain Layer)
abstract class IOfferRepository {
  Future<List<Offer>> getByBuyerId(String buyerId);
  Future<List<Offer>> getByFisherId(String fisherId);
  Future<Order?> acceptOffer(String offerId, UserRole role);
  Future<void> counterOffer(String offerId, UserRole role, OfferTerms terms);
  // ...
}

// Implementation (Data Layer)
class OfferRepositoryImpl implements IOfferRepository {
  final IOfferDataSource remoteDataSource;
  final IOfferDataSource localDataSource;
  final ConnectivityService connectivityService;
  // Coordinates between remote and local data sources
}
```

---

## Dependency Injection

### GetIt Service Locator

The app uses **GetIt** for dependency injection, configured in `lib/core/di/injector.dart`.

```dart
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core dependencies
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);
  sl.registerLazySingleton(() => TokenStorage());
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  // API Clients
  sl.registerLazySingleton(
    () => ApiClient.core(tokenStorage: sl()),
    instanceName: 'coreApiClient',
  );
  sl.registerLazySingleton(
    () => ApiClient.marketplace(tokenStorage: sl()),
    instanceName: 'marketplaceApiClient',
  );

  // Mode-specific initialization
  switch (AppConfig.mode) {
    case DataSourceMode.demo: _initDemoMode(); break;
    case DataSourceMode.local: _initLocalMode(dbHelper); break;
    case DataSourceMode.api: _initApiMode(dbHelper); break;
  }

  // Domain Services
  sl.registerLazySingleton(() => SessionService(...));
  sl.registerLazySingleton(() => NegotiationService(...));
  // ...
}
```

### Multi-Mode Support

The app supports three data source modes (configured via `AppConfig`):

| Mode    | Description              | Use Case            |
| ------- | ------------------------ | ------------------- |
| `demo`  | In-memory mock data      | Development/testing |
| `local` | SQLite-only              | Offline development |
| `api`   | Remote API + local cache | Production          |

---

## State Management

### Riverpod

The application uses **Riverpod** for reactive state management with the following provider types:

#### Provider Types Used

```dart
// Simple providers (DI access)
final sessionServiceProvider = Provider<SessionService>((ref) => sl<SessionService>());

// Future providers (async data fetching)
final currentUserProvider = FutureProvider<User?>((ref) async {
  final service = ref.watch(sessionServiceProvider);
  return await service.getCurrentUser();
});

// Family providers (parameterized)
final offersByProductProvider = FutureProvider.family
    .autoDispose<List<Offer>, String>((ref, productId) async {
  final repository = sl<IOfferRepository>();
  return repository.getByProductId(productId);
});

// StateNotifier providers (complex state)
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, bool>((ref) {
  return NotificationSettingsNotifier(ref);
});

// Stream providers (real-time updates)
final connectivityStatusProvider = StreamProvider<NetworkStatus>((ref) async* {
  final service = ref.watch(connectivityServiceProvider);
  yield* service.statusStream;
});
```

#### Key Providers

| Provider                       | Type                            | Purpose                       |
| ------------------------------ | ------------------------------- | ----------------------------- |
| `currentUserProvider`          | `FutureProvider<User?>`         | Current authenticated user    |
| `fisherCatchesProvider`        | `FutureProvider<List<Catch>>`   | Fisher's catches              |
| `fisherProductsProvider`       | `FutureProvider<List<Product>>` | Fisher's marketplace products |
| `buyerOffersProvider`          | `FutureProvider<List<Offer>>`   | Buyer's offers                |
| `fisherOffersProvider`         | `FutureProvider<List<Offer>>`   | Fisher's received offers      |
| `routerProvider`               | `Provider<GoRouter>`            | Navigation router             |
| `isOnlineProvider`             | `Provider<bool>`                | Network connectivity status   |
| `notificationSettingsProvider` | `StateNotifierProvider`         | Push notification toggle      |

#### Provider Invalidation

Providers can be invalidated to force refresh:

```dart
void setupProviderInvalidation(ProviderContainer container) {
  catchesDataSource.setOnCatchPublishedCallback(() {
    container.invalidate(fisherCatchesProvider);
    container.invalidate(fisherProductsProvider);
  });
}
```

---

## Navigation

### GoRouter

The app uses **GoRouter** for declarative navigation with authentication guards.

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,  // Refresh on auth changes
    redirect: (context, state) {
      // Authentication & role-based redirects
      if (AppConfig.isApiMode) {
        final isAuthenticated = ref.read(isAuthenticatedProvider).value ?? false;
        if (!isAuthenticated && !isLoginRoute) return '/login';
      }
      // ...
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/', builder: (_, __) => const RoleScreen()),
      GoRoute(
        path: '/fisher',
        builder: (_, __) => const Fisher(),
        routes: [
          GoRoute(path: 'catch-details/:id', builder: ...),
          GoRoute(path: 'offer-details/:id', builder: ...),
          GoRoute(path: 'notifications', builder: ...),
          // ...
        ],
      ),
      GoRoute(
        path: '/buyer',
        builder: (_, __) => const Buyer(),
        routes: [
          GoRoute(path: 'product-details/:id', builder: ...),
          GoRoute(path: 'offer-details/:id', builder: ...),
          // ...
        ],
      ),
    ],
  );
});
```

### Route Structure

```
/login                           # Authentication
/                                # Role selection
/fisher                          # Fisher dashboard
  /catch-details/:id             # Catch detail view
  /catch-report/:id              # Catch report
  /add-catch                     # Create new catch
  /order-details/:id             # Order details
  /offer-details/:id             # Offer negotiation
  /notifications                 # Notifications list
  /chat/:conversationId          # Chat screen
  /reviews/:userId               # User reviews
/buyer                           # Buyer marketplace
  /product-details/:id           # Product view
  /offer-details/:id             # Offer details
  /order-details/:id             # Order details
  /orders                        # Order history
  /notifications                 # Notifications
/user-profile/:role              # Profile settings
  /account-info                  # Account information
  /personal-information          # Edit profile
```

---

## Data Layer

### Data Sources Architecture

Each feature has three data source implementations sharing a common interface:

```
┌──────────────────────────────────────────────────────────────────┐
│                        IOfferDataSource                           │
│  (Interface: create, getById, getByBuyerId, update, delete, ...) │
└───────────────────────────┬──────────────────────────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
          ▼                 ▼                 ▼
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│ OffersApiDataSrc │ │ LocalOfferDataSrc│ │ DemoOfferDataSrc │
│   (Remote API)   │ │   (SQLite)       │ │   (In-memory)    │
└──────────────────┘ └──────────────────┘ └──────────────────┘
```

### Mappers

Mappers transform between domain entities and data models:

```dart
class OfferMapper {
  // Domain → Model (for persistence)
  static OfferModel toModel(Offer entity) {
    return OfferModel(
      id: entity.id,
      productId: entity.productId,
      currentPriceAmount: entity.currentTerms.totalPrice.amount,
      // ...
    );
  }

  // Model → Domain (for business logic)
  static Offer toEntity(OfferModel model) {
    return Offer(
      id: model.id,
      currentTerms: OfferTerms.create(
        totalPrice: Price.fromAmount(model.currentPriceAmount),
        weight: Weight.fromGrams(model.currentWeightGrams),
      ),
      // ...
    );
  }
}
```

---

## Local Storage & Database

### SQLite via sqflite

The app uses **sqflite** for local persistence with a centralized `DatabaseHelper`.

```dart
class DatabaseHelper {
  static const _databaseName = "siren_marketplace.db";
  static const _databaseVersion = 35;

  // Tables
  static const _usersTable = 'users';
  static const _productsTable = 'products';
  static const _catchesTable = 'catches';
  static const _offersTable = 'offers';
  static const _ordersTable = 'orders';
  static const _conversationsTable = 'conversations';
  static const _messagesTable = 'messages';
  static const _ratingsTable = 'ratings';

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
}
```

### Database Schema

| Table           | Key Columns                                         | Purpose              |
| --------------- | --------------------------------------------------- | -------------------- |
| `users`         | id, name, avatar_url, rating, role                  | User profiles        |
| `products`      | id, name, price_per_kg, available_weight, fisher_id | Marketplace products |
| `catches`       | catch_id, fisher_id, species, weight, status        | Fisher catches       |
| `offers`        | offer_id, catch_id, buyer_id, price, status         | Negotiations         |
| `orders`        | order_id, offer_id, status, terms                   | Completed orders     |
| `conversations` | id, buyer_id, fisher_id, last_message               | Chat conversations   |
| `messages`      | id, conversation_id, content, sender_id             | Chat messages        |
| `ratings`       | rating_id, order_id, rating_value, message          | User reviews         |

### Secure Storage

Sensitive data (JWT tokens) uses **flutter_secure_storage**:

```dart
class TokenStorage {
  static final _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    return DateTime.now().isAfter(expiry);
  }
}
```

---

## API Integration

### Dio HTTP Client

The app uses **Dio** for HTTP requests with separate clients for different API endpoints:

```dart
class ApiClient {
  late final Dio _dio;

  ApiClient({required String baseUrl, TokenStorage? tokenStorage}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Interceptors
    _dio.interceptors.add(ApiInterceptor(tokenStorage, _dio));
    _dio.interceptors.add(RetryInterceptor(...));
    _dio.interceptors.add(PrettyDioLogger(...));  // Debug only
  }

  // Factory constructors
  factory ApiClient.core({TokenStorage? tokenStorage}) =>
      ApiClient(baseUrl: ApiConfig.coreBaseUrl, tokenStorage: tokenStorage);

  factory ApiClient.marketplace({TokenStorage? tokenStorage}) =>
      ApiClient(baseUrl: ApiConfig.marketplaceBaseUrl, tokenStorage: tokenStorage);
}
```

### API Configuration

```dart
class ApiConfig {
  static String get coreBaseUrl =>
      dotenv.env['API_CORE_BASE_URL'] ?? 'https://api.core.dev.siren.dhi-cm.com/api/v1';

  static String get marketplaceBaseUrl =>
      dotenv.env['API_MARKETPLACE_BASE_URL'] ?? 'https://api.marketplace.dev.siren.dhi-cm.com/api/v1';

  // Endpoints
  static const String login = '/auth/login';
  static const String myProfile = '/accounts/my-profile';
  static const String fishCatches = '/fish-catches';
  static const String offers = '/offers';
  static const String products = '/products';
  // ...
}
```

### Interceptors

#### Authentication Interceptor

- Adds JWT bearer token to requests
- Proactively refreshes expired tokens before requests
- Handles 401 responses with automatic token refresh
- Clears session on refresh failure

```dart
class ApiInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, handler) async {
    // Skip auth for login endpoints
    if (options.path.contains('/auth/login')) return handler.next(options);

    // Proactive refresh if expired
    if (await _tokenStorage.isTokenExpired()) {
      final refreshed = await _tryRefreshToken();
      if (!refreshed) {
        await _tokenStorage.clearTokens();
        return handler.reject(DioException(...));
      }
    }

    // Add token header
    final token = await _tokenStorage.getAccessToken();
    options.headers['Authorization'] = 'Bearer $token';

    return handler.next(options);
  }
}
```

#### Retry Interceptor

Automatic retry with exponential backoff for transient failures:

```dart
RetryInterceptor(
  dio: _dio,
  retries: 3,
  retryDelays: [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 3),
  ],
  retryEvaluator: (error, attempt) {
    // Don't retry connection errors (offline)
    if (error.type == DioExceptionType.connectionError) return false;
    // Retry on 5xx and specific 4xx errors
    return DefaultRetryEvaluator({408, 429, 500, 502, 503, 504}).evaluate(...);
  },
)
```

---

## Caching Strategy

### Offline-First Pattern

The repository implementations follow an offline-first strategy:

```dart
class OfferRepositoryImpl implements IOfferRepository {
  @override
  Future<List<Offer>> getByBuyerId(String buyerId) async {
    // 1. Check connectivity
    if (await _isOffline) {
      // Return cached data when offline
      final models = await localDataSource.getByBuyerId(buyerId);
      return await _mapModelsToEntitiesWithUsers(models);
    }

    // 2. Try remote fetch
    try {
      final models = await remoteDataSource.getByBuyerId(buyerId);

      // 3. Cache result locally
      await localDataSource.saveBatch(models);

      // 4. Also cache related entities (users, products)
      await _cacheRelatedData(models);

      return await _mapModelsToEntitiesWithUsers(models);
    } catch (e) {
      // 5. Fallback to cache on error
      final models = await localDataSource.getByBuyerId(buyerId);
      return await _mapModelsToEntitiesWithUsers(models);
    }
  }
}
```

### Cache Hydration

Related entities are automatically cached when fetching data:

```dart
Future<void> _cacheRelatedData(List<OfferModel> models) async {
  // Cache Users (buyers and fishers)
  for (final model in models) {
    if (model.buyer != null) {
      await userRepository.saveLocal(User(...));
    }
    if (model.fisher != null) {
      await userRepository.saveLocal(User(...));
    }
  }

  // Cache Products
  final products = models
      .where((m) => m.product != null)
      .map((m) => ProductModel.fromDomain(m.product!))
      .toList();
  await localProductDataSource.saveBatch(products);
}
```

---

## Offline Support

### Connectivity Monitoring

```dart
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<NetworkStatus> _controller = StreamController.broadcast();

  Stream<NetworkStatus> get statusStream => _controller.stream;
  NetworkStatus get currentStatus => _currentStatus;

  Future<bool> get hasConnection async {
    final status = await checkConnectivity();
    return status == NetworkStatus.online;
  }
}

// Riverpod providers for UI consumption
final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityStatusProvider).valueOrNull;
  return status != NetworkStatus.offline;
});
```

### Offline Indicator

```dart
// In main.dart
MaterialApp.router(
  builder: (context, child) {
    return Stack(
      children: [
        if (child != null) child,
        Positioned(top: 50, right: 50, child: const OfflineIndicator()),
      ],
    );
  },
)
```

---

## Authentication

### Login Flow

```dart
class SessionService {
  Future<User> loginWithApi(String email, String password) async {
    // 1. Authenticate with API
    final authResponse = await _authApiDataSource.login(email, password);

    // 2. Store JWT token securely
    await _tokenStorage.saveToken(
      authResponse.token,
      userId: authResponse.id.toString(),
      expiry: authResponse.tokenExpireAt,
    );

    // 3. Map API response to domain entity
    final user = AccountApiMapper.toDomain(authResponse.account);

    // 4. Persist session locally
    await _sessionRepository.saveCurrentUser(user);
    await _sessionRepository.saveCurrentRole(user.currentRole);

    return user;
  }
}
```

### Session Validation

- Token expiry checked before each API request
- Automatic token refresh when expired
- Session cleared on refresh failure
- Offline mode skips token validation

---

## Push Notifications

### Firebase Cloud Messaging

```dart
class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(...);
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<String?> getToken() async => await _messaging.getToken();

  void setupForegroundMessageHandler(Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessage.listen(handler);
  }
}
```

### Device Token Registration

```dart
class NotificationSettingsNotifier extends StateNotifier<bool> {
  Future<bool> toggleNotifications(bool enable) async {
    if (enable) {
      // 1. Request permission
      final granted = await service.requestPermission();
      if (!granted) return false;

      // 2. Get/register FCM token
      final fcmToken = await service.getToken();
      await repository.registerDeviceToken(
        token: fcmToken,
        platform: service.getPlatform(),
        deviceId: deviceId,
      );

      // 3. Enable via API
      await repository.toggleNotifications(true);
    }
    // ...
  }
}
```

---

## Key Technologies

| Category               | Technology               | Purpose              |
| ---------------------- | ------------------------ | -------------------- |
| **Framework**          | Flutter 3.10+            | Cross-platform UI    |
| **State Management**   | Riverpod 2.6             | Reactive state       |
| **DI**                 | GetIt                    | Service locator      |
| **Navigation**         | GoRouter                 | Declarative routing  |
| **HTTP**               | Dio                      | API requests         |
| **Database**           | sqflite                  | Local SQLite storage |
| **Secure Storage**     | flutter_secure_storage   | JWT tokens           |
| **Push Notifications** | firebase_messaging       | FCM integration      |
| **Connectivity**       | connectivity_plus        | Network monitoring   |
| **Serialization**      | json_annotation, freezed | Model generation     |
| **Image Loading**      | cached_network_image     | Image caching        |
| **Location**           | geolocator, geocoding    | GPS features         |

---

## Environment Configuration

The app uses `.env` files for environment-specific configuration:

```env
# API Configuration
API_CORE_BASE_URL=https://api.core.dev.siren.dhi-cm.com/api/v1
API_MARKETPLACE_BASE_URL=https://api.marketplace.dev.siren.dhi-cm.com/api/v1

# Feature Flags
USE_API_DATA_SOURCE=true
ENABLE_OFFLINE_MODE=true
```

---

## Summary

The Siren Marketplace app demonstrates a well-architected Flutter application with:

- ✅ **Clean Architecture** with clear layer separation
- ✅ **Repository Pattern** abstracting data access
- ✅ **Multi-mode data sources** (API, Local, Demo)
- ✅ **Offline-first caching** with automatic sync
- ✅ **Reactive state management** via Riverpod
- ✅ **Type-safe navigation** with GoRouter
- ✅ **Secure authentication** with JWT token management
- ✅ **Push notifications** via Firebase Cloud Messaging
- ✅ **Robust error handling** with retry mechanisms

This architecture ensures maintainability, testability, and scalability as the application grows.
