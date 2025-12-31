import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_offer_repository.dart';
import 'package:siren_marketplace/core/providers/catch_filter_provider.dart';
import 'package:siren_marketplace/core/providers/conversation_providers.dart';
import 'package:siren_marketplace/core/providers/notification_filter_provider.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/types/extensions.dart';

/// Provider to fetch an Offer by ID
final offerProvider = FutureProvider.family<Offer?, String>((ref, id) async {
  final repository = sl<IOfferRepository>();
  return repository.getById(id);
});

/// Provider to fetch offers for a specific product (auto-dispose)
final offersByProductProvider = FutureProvider.family
    .autoDispose<List<Offer>, String>((ref, productId) async {
      // Get current user to determine role context
      final user = await ref.watch(currentUserProvider.future);
      final role = user?.currentRole;

      final repository = sl<IOfferRepository>();
      return repository.getByProductId(productId, role: role);
    });

/// Provider to fetch offers for the current fisher user
/// Automatically refreshes when user changes
final fisherOffersProvider = FutureProvider.autoDispose<List<Offer>>((
  ref,
) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null || user.currentRole != UserRole.fisher) return [];

  final repository = sl<IOfferRepository>();
  return repository.getByFisherId(user.id);
});

/// Provider to fetch offers for the current buyer user
/// Automatically refreshes when user changes
final buyerOffersProvider = FutureProvider<List<Offer>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null || user.currentRole != UserRole.buyer) return [];

  final repository = sl<IOfferRepository>();
  return repository.getByBuyerId(user.id);
});

/// Provider to count pending offers with updates for fisher
/// Combined count: offer updates + unread messages
final fisherPendingOffersCountProvider = Provider.autoDispose<int>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return 0;

  // Count offer updates
  final offersAsync = ref.watch(fisherOffersProvider);
  final offerCount = offersAsync.when(
    data: (offers) => offers.where((o) => o.hasUpdateForFisher).length,
    loading: () => 0,
    error: (_, __) => 0,
  );

  // Count unread conversations
  final conversationsAsync = ref.watch(userConversationsProvider(user.id));
  final messageCount = conversationsAsync.when(
    data: (conversations) =>
        conversations.where((c) => c.hasUnreadMessagesFor(user.id)).length,
    loading: () => 0,
    error: (_, __) => 0,
  );

  return offerCount + messageCount;
});

/// Provider to count offers with updates for buyer (for notification badge)
/// Combined count: offer updates + unread messages
final buyerNotificationCountProvider = Provider.autoDispose<int>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return 0;

  // Count offer updates
  final offersAsync = ref.watch(buyerOffersProvider);
  final offerCount = offersAsync.when(
    data: (offers) => offers.where((o) => o.hasUpdateForBuyer).length,
    loading: () => 0,
    error: (_, __) => 0,
  );

  // Count unread conversations
  final conversationsAsync = ref.watch(userConversationsProvider(user.id));
  final messageCount = conversationsAsync.when(
    data: (conversations) =>
        conversations.where((c) => c.hasUnreadMessagesFor(user.id)).length,
    loading: () => 0,
    error: (_, __) => 0,
  );

  return offerCount + messageCount;
});

/// Provider for filtered and sorted offers for a specific catch
/// Combines offers with filter state for automatic updates
final filteredOffersProvider = Provider.autoDispose.family<List<Offer>, String>(
  (ref, productId) {
    final offersAsync = ref.watch(offersByProductProvider(productId));
    final filterState = ref.watch(catchFilterProvider);

    return offersAsync.when(
      data: (offers) {
        // Apply filters
        var filtered = offers.where((offer) {
          if (filterState.activeStatuses.isEmpty) return true;
          final statusName = offer.status.name.capitalize();
          return filterState.activeStatuses.contains(statusName);
        }).toList();

        // Apply sort
        filtered.sort((a, b) {
          final dateA = a.dateCreated;
          final dateB = b.dateCreated;
          return filterState.activeSortBy == "ascending"
              ? dateA.compareTo(dateB)
              : dateB.compareTo(dateA);
        });

        return filtered;
      },
      loading: () => [],
      error: (_, __) => [],
    );
  },
);

/// Provider for filtered and sorted notification offers
/// Used in the shared notifications screen
final filteredNotificationOffersProvider =
    Provider.autoDispose<AsyncValue<List<Offer>>>((ref) {
      final user = ref.watch(currentUserProvider).value;
      if (user == null) return const AsyncValue.loading();

      final offersAsync = user.currentRole == UserRole.fisher
          ? ref.watch(fisherOffersProvider)
          : ref.watch(buyerOffersProvider);

      final filterState = ref.watch(notificationFilterProvider);

      return offersAsync.whenData((offers) {
        // Apply filters
        var filtered = offers.where((offer) {
          if (filterState.activeStatuses.isEmpty) return true;
          return filterState.activeStatuses.contains(offer.status);
        }).toList();

        // Apply sort by dateUpdated (most recent updates first)
        filtered.sort((a, b) {
          final dateA = a.dateUpdated;
          final dateB = b.dateUpdated;
          return filterState.activeSortBy == "ascending"
              ? dateA.compareTo(dateB)
              : dateB.compareTo(dateA);
        });

        return filtered;
      });
    });
