import '../entities/catch.dart';
import '../repositories/i_catch_repository.dart';
import '../repositories/i_user_repository.dart';
import '../value_objects/price_per_kg.dart';

/// Service handling marketplace operations
class MarketplaceService {
  final ICatchRepository _catchRepository;
  final IUserRepository _userRepository;

  MarketplaceService({
    required ICatchRepository catchRepository,
    required IUserRepository userRepository,
  }) : _catchRepository = catchRepository,
       _userRepository = userRepository;

  /// Create a new catch listing
  Future<Catch> createCatch({required Catch catchItem}) async {
    // Validate fisher exists
    final fisher = await _userRepository.getById(catchItem.fisherId);
    if (fisher == null) {
      throw ArgumentError('Fisher not found');
    }

    await _catchRepository.create(catchItem);
    return catchItem;
  }

  /// Get all available catches on marketplace
  Future<List<Catch>> getMarketplaceCatches() async {
    return await _catchRepository.getAvailableCatches();
  }

  /// Get catches for a specific fisher
  Future<List<Catch>> getFisherCatches(String fisherId) async {
    return await _catchRepository.getByFisherId(fisherId);
  }

  /// Remove a catch from marketplace
  Future<void> removeCatch(String catchId, String fisherId) async {
    final catchItem = await _catchRepository.getById(catchId);
    if (catchItem == null) {
      throw ArgumentError('Catch not found');
    }

    if (catchItem.fisherId != fisherId) {
      throw StateError('Only the owner can remove this catch');
    }

    final removed = catchItem.markAsRemoved();
    await _catchRepository.update(removed);
  }

  /// Update catch pricing
  Future<Catch> updateCatchPricing({
    required String catchId,
    required String fisherId,
    required PricePerKg newPricePerKg,
  }) async {
    final catchItem = await _catchRepository.getById(catchId);
    if (catchItem == null) {
      throw ArgumentError('Catch not found');
    }

    if (catchItem.fisherId != fisherId) {
      throw StateError('Only the owner can update pricing');
    }

    final newTotalPrice = newPricePerKg.calculateTotalPrice(
      catchItem.availableWeight,
    );

    final updated = catchItem.copyWith(
      pricePerKg: newPricePerKg,
      totalPrice: newTotalPrice,
    );

    await _catchRepository.update(updated);
    return updated;
  }
}
