import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:siren_marketplace/core/data/datasources/order_datasource.dart';
import 'package:siren_marketplace/core/data/persistence/catch_entity.dart'; // Import CatchEntity
import 'package:siren_marketplace/core/data/persistence/order_entity.dart';
import 'package:siren_marketplace/core/data/repositories/catch_repository.dart';
import 'package:siren_marketplace/core/data/repositories/offer_repository.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/domain/models/catch.dart';
import 'package:siren_marketplace/core/domain/models/order.dart';

class OrderRepository {
  final OrderDataSource dataSource;
  final OfferRepository offerRepository;
  final CatchRepository catchRepository;
  final UserRepository userRepository;

  OrderRepository({
    required this.dataSource,
    required this.offerRepository,
    required this.catchRepository,
    required this.userRepository,
  });

  Future<void> insertOrder(Order order) async {
    final entity = OrderEntity.fromDomain(order);
    await dataSource.insertOrder(entity);
  }

  Future<Order?> getOrderById(String id) async {
    final entity = await dataSource.getOrderById(id);
    if (entity == null) return null;

    final offer = await offerRepository.getOfferById(entity.offerId);
    if (offer == null) {
      debugPrint(
        'OrderRepository: Offer with ID ${entity.offerId} not found for Order ${entity.id}',
      );
      return null;
    }

    Catch catchModel;
    try {
      final Map<String, dynamic> catchMap = jsonDecode(
        entity.catchSnapshotJson,
      );
      // Correctly use CatchEntity to deserialize the snapshot into a domain Catch object
      catchModel = CatchEntity.fromMap(catchMap).toDomain();
    } catch (e) {
      debugPrint(
        'Error deserializing Catch snapshot for Order ${entity.id}: $e',
      );
      // Fallback to an empty catch or throw an error based on your domain rules
      // For now, returning null for the order if catch snapshot is invalid
      return null;
    }

    return Order(
      id: entity.id,
      offer: offer,
      fisherId: entity.fisherId,
      buyerId: entity.buyerId,
      catchSnapshotJson: entity.catchSnapshotJson,
      dateUpdated: entity.dateUpdated,
      catchModel: catchModel,
      hasRatedBuyer: entity.hasRatedBuyer,
      hasRatedFisher: entity.hasRatedFisher,
      buyerRatingValue: entity.buyerRatingValue,
      buyerRatingMessage: entity.buyerRatingMessage,
      fisherRatingValue: entity.fisherRatingValue,
      fisherRatingMessage: entity.fisherRatingMessage,
    );
  }

  Future<List<Order>> getAllOrders() async {
    final entities = await dataSource.getAllOrders();
    final List<Order> orders = [];

    for (final entity in entities) {
      final order = await getOrderById(entity.id);
      if (order != null) {
        orders.add(order);
      }
    }
    return orders;
  }

  Future<List<Order>> getOrdersByUserId(String userId) async {
    final entities = await dataSource.getOrdersByUserId(userId);
    final List<Order> orders = [];

    for (final entity in entities) {
      final order = await getOrderById(entity.id);
      if (order != null) {
        orders.add(order);
      }
    }
    return orders;
  }

  Future<void> updateOrder(Order order) async {
    final entity = OrderEntity.fromDomain(order);
    await dataSource.updateOrder(entity);
  }

  Future<void> deleteOrder(String id) async {
    await dataSource.deleteOrder(id);
  }

  Future<Order?> getOrderByOfferId(String offerId) async {
    final entity = await dataSource.getOrderByOfferId(offerId);
    if (entity == null) return null;
    return getOrderById(entity.id);
  }
}
