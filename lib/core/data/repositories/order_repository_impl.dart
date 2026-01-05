import '../../domain/entities/order.dart';
import '../../domain/enums/order_status.dart';
import '../../domain/exceptions/not_found_exception.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../datasources/interfaces/i_order_datasource.dart';
import '../datasources/api/orders_api_data_source.dart';
import '../mappers/order_mapper.dart';

class OrderRepositoryImpl implements IOrderRepository {
  final IOrderDataSource remoteDataSource;
  final IOrderDataSource localDataSource;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

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
    // 1. Try Remote (Embedded)
    try {
      final order = await getByIdWithEmbeddedData(orderId);
      if (order != null) return order;
    } catch (_) {}

    // 2. Try Remote (Standard)
    try {
      final model = await remoteDataSource.getById(orderId);
      if (model != null) {
        await localDataSource.saveBatch([model]);
        return OrderMapper.toEntity(model);
      }
    } catch (_) {}

    // 3. Fallback to Local
    final localModel = await localDataSource.getById(orderId);
    if (localModel == null) {
      throw NotFoundException(
        "Order not found",
        entityType: 'Order',
        entityId: orderId,
      );
    }
    return OrderMapper.toEntity(localModel);
  }

  @override
  Future<Order?> getByOfferId(String offerId) async {
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
