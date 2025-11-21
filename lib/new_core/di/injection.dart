import '../config/app_config.dart';
import '../data/datasources/demo/demo_datasource.dart';
import '../data/repositories/catch_repository_impl.dart';
import '../data/repositories/offer_repository_impl.dart';
import '../data/repositories/order_repository_impl.dart';
import '../data/repositories/review_repository_impl.dart';
import '../data/repositories/session_repository_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/repositories/i_catch_repository.dart';
import '../domain/repositories/i_offer_repository.dart';
import '../domain/repositories/i_order_repository.dart';
import '../domain/repositories/i_review_repository.dart';
import '../domain/repositories/i_session_repository.dart';
import '../domain/repositories/i_user_repository.dart';
import '../domain/services/expiration_service.dart';
import '../domain/services/marketplace_service.dart';
import '../domain/services/negotiation_service.dart';
import '../domain/services/order_service.dart';
import '../domain/services/rating_service.dart';
import '../domain/services/session_service.dart';

/// Dependency Injection Container
///
/// This class manages all app dependencies and allows easy switching
/// between demo/local/api data sources.
class DI {
  // Singleton instance
  static final DI _instance = DI._internal();
  factory DI() => _instance;
  DI._internal();

  // Data Sources (shared for demo mode)
  DemoDataSources? _demoDataSources;

  // Repositories
  IUserRepository? _userRepository;
  ICatchRepository? _catchRepository;
  IOfferRepository? _offerRepository;
  IOrderRepository? _orderRepository;
  IReviewRepository? _reviewRepository;
  ISessionRepository? _sessionRepository;

  // Services
  NegotiationService? _negotiationService;
  ExpirationService? _expirationService;
  RatingService? _ratingService;
  MarketplaceService? _marketplaceService;
  OrderService? _orderService;
  SessionService? _sessionService;

  /// Initialize DI container (call on app start)
  Future<void> init() async {
    // Clear existing instances when switching modes
    _reset();

    switch (AppConfig.mode) {
      case DataSourceMode.demo:
        await _initDemoMode();
        break;
      case DataSourceMode.local:
        await _initLocalMode();
        break;
      case DataSourceMode.api:
        await _initApiMode();
        break;
    }
  }

  void _reset() {
    _demoDataSources = null;
    _userRepository = null;
    _catchRepository = null;
    _offerRepository = null;
    _orderRepository = null;
    _reviewRepository = null;
    _sessionRepository = null;
    _negotiationService = null;
    _expirationService = null;
    _ratingService = null;
    _marketplaceService = null;
    _orderService = null;
    _sessionService = null;
  }

  // =========================================================================
  // DEMO MODE INITIALIZATION
  // =========================================================================
  Future<void> _initDemoMode() async {
    // Create demo data sources with shared storage
    _demoDataSources = DemoDataSourceFactory.create();

    // Create repositories using demo data sources
    _userRepository = UserRepositoryImpl(
      dataSource: _demoDataSources!.userDataSource,
    );
    _catchRepository = CatchRepositoryImpl(
      dataSource: _demoDataSources!.catchDataSource,
    );
    _offerRepository = OfferRepositoryImpl(
      dataSource: _demoDataSources!.offerDataSource,
    );
    _orderRepository = OrderRepositoryImpl(
      dataSource: _demoDataSources!.orderDataSource,
    );
    _reviewRepository = ReviewRepositoryImpl(
      dataSource: _demoDataSources!.reviewDataSource,
    );
    _sessionRepository = SessionRepositoryImpl(
      dataSource: _demoDataSources!.sessionDataSource,
    );

    // Create services
    _createServices();
  }

  // =========================================================================
  // LOCAL MODE INITIALIZATION (SQLite)
  // =========================================================================
  Future<void> _initLocalMode() async {
    // TODO: Implement SQLite data sources
    // final db = await DatabaseHelper().database;
    // final sqliteUserDs = SqliteUserDataSource(db: db);
    // final sqliteCatchDs = SqliteCatchDataSource(db: db);
    // ... etc

    throw UnimplementedError('Local mode not yet implemented');
  }

  // =========================================================================
  // API MODE INITIALIZATION
  // =========================================================================
  Future<void> _initApiMode() async {
    // TODO: Implement API data sources
    // final httpClient = HttpClient();
    // final apiUserDs = ApiUserDataSource(client: httpClient);
    // final apiCatchDs = ApiCatchDataSource(client: httpClient);
    // ... etc

    throw UnimplementedError('API mode not yet implemented');
  }

  // =========================================================================
  // SERVICE CREATION
  // =========================================================================
  void _createServices() {
    _negotiationService = NegotiationService(
      offerRepository: _offerRepository!,
      orderRepository: _orderRepository!,
      catchRepository: _catchRepository!,
    );

    _expirationService = ExpirationService(catchRepository: _catchRepository!);

    _ratingService = RatingService(
      reviewRepository: _reviewRepository!,
      orderRepository: _orderRepository!,
      userRepository: _userRepository!,
    );

    _marketplaceService = MarketplaceService(
      catchRepository: _catchRepository!,
      userRepository: _userRepository!,
    );

    _orderService = OrderService(
      orderRepository: _orderRepository!,
      offerRepository: _offerRepository!,
      catchRepository: _catchRepository!,
    );

    _sessionService = SessionService(
      sessionRepository: _sessionRepository!,
      userRepository: _userRepository!,
    );
  }

  // =========================================================================
  // GETTERS (Public API)
  // =========================================================================

  // Repositories
  IUserRepository get userRepository {
    if (_userRepository == null) {
      throw StateError('DI not initialized. Call DI().init() first.');
    }
    return _userRepository!;
  }

  ICatchRepository get catchRepository {
    if (_catchRepository == null) {
      throw StateError('DI not initialized. Call DI().init() first.');
    }
    return _catchRepository!;
  }

  IOfferRepository get offerRepository {
    if (_offerRepository == null) {
      throw StateError('DI not initialized. Call DI().init() first.');
    }
    return _offerRepository!;
  }

  IOrderRepository get orderRepository {
    if (_orderRepository == null) {
      throw StateError('DI not initialized. Call DI().init() first.');
    }
    return _orderRepository!;
  }

  IReviewRepository get reviewRepository {
    if (_reviewRepository == null) {
      throw StateError('DI not initialized. Call DI().init() first.');
    }
    return _reviewRepository!;
  }

  ISessionRepository get sessionRepository {
    if (_sessionRepository == null) {
      throw StateError('DI not initialized. Call DI().init() first.');
    }
    return _sessionRepository!;
  }

  // Services
  NegotiationService get negotiationService {
    if (_negotiationService == null) {
      throw StateError('DI not initialized. Call DI().init() first.');
    }
    return _negotiationService!;
  }

  ExpirationService get expirationService {
    if (_expirationService == null) {
      throw StateError('DI not initialized. Call DI().init() first.');
    }
    return _expirationService!;
  }

  RatingService get ratingService {
    if (_ratingService == null) {
      throw StateError('DI not initialized. Call DI().init() first.');
    }
    return _ratingService!;
  }

  MarketplaceService get marketplaceService {
    if (_marketplaceService == null) {
      throw StateError('DI not initialized. Call DI().init() first.');
    }
    return _marketplaceService!;
  }

  OrderService get orderService {
    if (_orderService == null) {
      throw StateError('DI not initialized. Call DI().init() first.');
    }
    return _orderService!;
  }

  SessionService get sessionService {
    if (_sessionService == null) {
      throw StateError('DI not initialized. Call DI().init() first.');
    }
    return _sessionService!;
  }
}
