import '../api/models/catch_api_models.dart';
import '../models/catch_model.dart';
import '../models/species_model.dart';

class CatchApiMapper {
  static CatchModel toDomain(CatchApiModel apiModel) {
    // Extract images from fishCatchImages array
    final images = apiModel.fishCatchImages
        .map((img) => img.imageUrl ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    // Convert weights from kg to grams for internal model
    final initialWeightGrams = ((apiModel.estimatedWeightInKg ?? 0) * 1000)
        .toInt();
    final publishedWeightGrams = ((apiModel.publishedWeightInKg ?? 0) * 1000)
        .toInt();

    // Convert price_per_kg to cents
    final pricePerKgCents = ((apiModel.pricePerKg ?? 0) * 100).toInt();
    final finalPriceCents = ((apiModel.finalPrice ?? 0) * 100).toInt();

    return CatchModel(
      id: apiModel.id.toString(),
      name: apiModel.name ?? apiModel.species?.name ?? 'Catch #${apiModel.id}',
      datePosted: apiModel.createdAt ?? DateTime.now().toIso8601String(),
      initialWeightGrams: initialWeightGrams,
      availableWeightGrams: publishedWeightGrams,
      pricePerKgAmount: pricePerKgCents,
      totalPriceAmount: finalPriceCents,
      size: apiModel.averageSizeInCm?.toString() ?? 'Unknown',
      market: apiModel.market ?? 'Unknown Market',
      images: images,
      species:
          apiModel.species ??
          const SpeciesModel(id: 'unknown', name: 'Unknown', image: ''),
      fisherId: apiModel.account?.id?.toString() ?? 'unknown_fisher',
      status: apiModel.status ?? 'UPLOADED',
      // Location and observation data
      observationId: '',
      locationName: '',
      latitude: 0.0,
      longitude: 0.0,
      // Gear and fishing data from API
      meshSize: apiModel.gear?.gearMeshSizeInFinger,
      gearLength: apiModel.gear?.gearLengthInMeter,
      gearWidth: null, // Not in API
      gearNature: apiModel.gear?.gearNature,
      waterDepth: apiModel.waterDepthInMeter,
      fishingTime: apiModel.fishingTimeInHour,
      numberOfShrimps: apiModel.estimatedSize,
    );
  }

  static CreateCatchRequest toRequest(CatchModel model) {
    return CreateCatchRequest(
      name: model.name,
      initialWeightGrams: model.initialWeightGrams,
      pricePerKgAmount: model.pricePerKgAmount,
      size: model.size,
      speciesId: model.species.id,
      market: model.market,
      images: model.images,
    );
  }
}
