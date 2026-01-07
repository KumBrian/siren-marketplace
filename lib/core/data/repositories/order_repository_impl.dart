import '../../domain/entities/order.dart';
import '../../domain/enums/order_status.dart';
import '../../domain/exceptions/not_found_exception.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../datasources/interfaces/i_order_datasource.dart';
import '../datasources/api/orders_api_data_source.dart';
import '../mappers/order_mapper.dart';
import '../../services/connectivity_service.dart';

class OrderRepositoryImpl implements IOrderRepository {
  final IOrderDataSource remoteDataSource;
  final IOrderDataSource localDataSource;
  final ConnectivityService connectivityService;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  Future<bool> get _isOffline async {
    final status = await connectivityService.checkConnectivity();
    return status == NetworkStatus.offline;
  }

  @override
  Future<String> create(Order order) async {
    final model = OrderMapper.toModel(order);
    // Create remotely
    final id = await remoteDataSource.create(model);
    // Note: Creating an order usually returns immediate data or we fetch it.
    // For now we don't cache the result of create immediately unless we fetch it back.
    return id;
  }

  @override
  Future<List<Order>> getAllOrders() async {
    if (await _isOffline) {
      final models = await localDataSource.getAllOrders();
      return models.map((m) => OrderMapper.toEntity(m)).toList();
    }

    try {
      final models = await remoteDataSource.getAllOrders();
      await localDataSource.saveBatch(models);
      return models.map((m) => OrderMapper.toEntity(m)).toList();
    } catch (e) {
      final models = await localDataSource.getAllOrders();
      return models.map((m) => OrderMapper.toEntity(m)).toList();
    }
  }

  @override
  Future<Order> getById(String orderId) async {
    final isOffline = await _isOffline;
    print('DEBUG OrderRepository: getById($orderId), isOffline=$isOffline');

    // Optimization: Skip remote if offline
    if (isOffline) {
      print('DEBUG OrderRepository: Offline mode, fetching local only');
      return _getLocalOrder(orderId);
    }

    // 1. Try Remote (Embedded)
    try {
      print('DEBUG OrderRepository: Trying remote fetch with embedded data');
      final order = await getByIdWithEmbeddedData(orderId);
      if (order != null) {
        print('DEBUG OrderRepository: Remote fetch successful (embedded)');
        return order;
      }
    } catch (e) {
      print('DEBUG OrderRepository: Remote fetch (embedded) failed: $e');
      // ignore
    }

    // 2. Try Remote (Standard)
    try {
      print('DEBUG OrderRepository: Trying remote fetch (standard)');
      final model = await remoteDataSource.getById(orderId);
      if (model != null) {
        print(
          'DEBUG OrderRepository: Remote fetch successful (standard), saving to local',
        );
        await localDataSource.saveBatch([model]);
        return OrderMapper.toEntity(model);
      }
    } catch (e) {
      print('DEBUG OrderRepository: Remote fetch (standard) failed: $e');
      // Fallback defined below
    }

    // 3. Fallback to Local
    print(
      'DEBUG OrderRepository: Remote failed or returned null, failing back to local',
    );
    return _getLocalOrder(orderId);
  }

  Future<Order> _getLocalOrder(String orderId) async {
    print('DEBUG OrderRepository: _getLocalOrder($orderId)');
    final localModel = await localDataSource.getById(orderId);
    if (localModel == null) {
      print('DEBUG OrderRepository: Order not found in local DB');
      throw NotFoundException(
        "Order not found",
        entityType: 'Order',
        entityId: orderId,
      );
    }
    print('DEBUG OrderRepository: Found local order, mapping to entity');
    try {
      final entity = OrderMapper.toEntity(localModel);
      print('DEBUG OrderRepository: Mapped entity successfully: ${entity.id}');
      return entity;
    } catch (e) {
      print('DEBUG OrderRepository: Error mapping local model to entity: $e');
      rethrow;
    }
  }

  @override
  Future<Order?> getByOfferId(String offerId) async {
    if (await _isOffline) {
      final localModel = await localDataSource.getByOfferId(offerId);
      return localModel != null ? OrderMapper.toEntity(localModel) : null;
    }

    try {
      final model = await remoteDataSource.getByOfferId(offerId);
      if (model != null) {
        await localDataSource.saveBatch([model]);
        return OrderMapper.toEntity(model);
      }
    } catch (_) {}

    final localModel = await localDataSource.getByOfferId(offerId);
    return localModel != null ? OrderMapper.toEntity(localModel) : null;
  }

  @override
  Future<List<Order>> getByUserId(String userId) async {
    if (await _isOffline) {
      final models = await localDataSource.getByUserId(userId);
      return models.map((m) => OrderMapper.toEntity(m)).toList();
    }

    try {
      final models = await remoteDataSource.getByUserId(userId);
      await localDataSource.saveBatch(models);
      return models.map((m) => OrderMapper.toEntity(m)).toList();
    } catch (e) {
      final models = await localDataSource.getByUserId(userId);
      return models.map((m) => OrderMapper.toEntity(m)).toList();
    }
  }

  Future<List<Order>> getByUserIdWithEmbeddedData(String userId) async {
    if (await _isOffline) {
      return getByUserId(userId);
    }

    try {
      // 1. Remote fetch with embedded data
      if (remoteDataSource is OrdersApiDataSource) {
        final apiModels = await (remoteDataSource as OrdersApiDataSource)
            .getOrdersWithEmbeddedData(userId);

        final entities = apiModels
            .map((api) => OrderMapper.fromApi(api))
            .toList();

        // 2. Cache 'em (need to convert ApiModel -> Model for local DB)
        final modelsToCache = entities
            .map((e) => OrderMapper.toModel(e))
            .toList();
        await localDataSource.saveBatch(modelsToCache);

        return entities;
      } else {
        // Not API mode, delegate to standard getByUserId (which handles its own caching/logic)
        return getByUserId(userId);
      }
    } catch (e) {
      // 3. Fallback to local
      // Directly call local source to avoid redundant remote attempt
      final models = await localDataSource.getByUserId(userId);
      return models.map((m) => OrderMapper.toEntity(m)).toList();
    }
  }

  /// Get single order by ID with embedded product data (more efficient)
  Future<Order?> getByIdWithEmbeddedData(String orderId) async {
    if (await _isOffline) {
      return null; // Let caller fallback or handle it
    }

    try {
      if (remoteDataSource is OrdersApiDataSource) {
        final apiModel = await (remoteDataSource as OrdersApiDataSource)
            .getByIdWithEmbeddedData(orderId);

        if (apiModel != null) {
          final entity = OrderMapper.fromApi(apiModel);
          // Cache
          await localDataSource.saveBatch([OrderMapper.toModel(entity)]);
          return entity;
        }
      }
    } catch (_) {}

    // Fallback handled in getById caller or returns null
    return null;
  }

  @override
  Future<List<Order>> getByFisherId(String fisherId) async {
    if (await _isOffline) {
      final models = await localDataSource.getByFisherId(fisherId);
      return models.map((m) => OrderMapper.toEntity(m)).toList();
    }

    try {
      final models = await remoteDataSource.getByFisherId(fisherId);
      await localDataSource.saveBatch(models);
      return models.map((m) => OrderMapper.toEntity(m)).toList();
    } catch (e) {
      final models = await localDataSource.getByFisherId(fisherId);
      return models.map((m) => OrderMapper.toEntity(m)).toList();
    }
  }

  @override
  Future<List<Order>> getByBuyerId(String buyerId) async {
    if (await _isOffline) {
      final models = await localDataSource.getByBuyerId(buyerId);
      return models.map((m) => OrderMapper.toEntity(m)).toList();
    }

    try {
      final models = await remoteDataSource.getByBuyerId(buyerId);
      await localDataSource.saveBatch(models);
      return models.map((m) => OrderMapper.toEntity(m)).toList();
    } catch (e) {
      final models = await localDataSource.getByBuyerId(buyerId);
      return models.map((m) => OrderMapper.toEntity(m)).toList();
    }
  }

  @override
  Future<List<Order>> getByStatus(OrderStatus status) async {
    if (await _isOffline) {
      final models = await localDataSource.getByStatus(status);
      return models.map((m) => OrderMapper.toEntity(m)).toList();
    }

    try {
      final models = await remoteDataSource.getByStatus(status);
      await localDataSource.saveBatch(models);
      return models.map((m) => OrderMapper.toEntity(m)).toList();
    } catch (e) {
      final models = await localDataSource.getByStatus(status);
      return models.map((m) => OrderMapper.toEntity(m)).toList();
    }
  }

  @override
  Future<List<Order>> getReviewableOrders(String userId) async {
    // This relies on getByStatus(completed) or similar
    final completed = await getByStatus(OrderStatus.completed);
    return completed.where((o) => o.canBeReviewedBy(userId)).toList();
  }

  @override
  Future<void> update(Order order) async {
    final model = OrderMapper.toModel(order);
    await remoteDataSource.update(model);
    await localDataSource.update(model);
  }

  @override
  Future<void> delete(String orderId) async {
    await remoteDataSource.delete(orderId);
    try {
      await localDataSource.delete(orderId);
    } catch (_) {}
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    return await localDataSource.transaction(action);
  }

  @override
  Future<Order> relistOrder(String orderId, String cancellationReason) async {
    final model = await remoteDataSource.relistOrder(
      orderId,
      cancellationReason,
    );
    if (model == null) {
      throw Exception('Failed to relist order');
    }
    await localDataSource.saveBatch([model]);
    return OrderMapper.toEntity(model);
  }
}
