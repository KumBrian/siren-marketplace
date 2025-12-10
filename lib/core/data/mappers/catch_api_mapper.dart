import '../api/models/catch_api_models.dart';
import '../models/catch_model.dart';
import '../models/species_model.dart';

class CatchApiMapper {
  static CatchModel toDomain(CatchApiModel apiModel) {
    return CatchModel(
      id: apiModel.id.toString(),
      name: apiModel.name ?? 'Unknown Catch',
      datePosted: apiModel.createdAt ?? DateTime.now().toIso8601String(),
      initialWeightGrams: apiModel.initialWeightGrams ?? 0,
      availableWeightGrams: apiModel.availableWeightGrams ?? 0,
      pricePerKgAmount: apiModel.pricePerKgAmount ?? 0,
      totalPriceAmount: apiModel.totalPriceAmount ?? 0,
      size: apiModel.size ?? 'Medium',
      market: apiModel.market ?? 'Default Market',
      images: apiModel.images,
      species:
          apiModel.species ??
          const SpeciesModel(id: 'unknown', name: 'Unknown', image: ''),
      fisherId: apiModel.fisher?.id?.toString() ?? 'unknown_fisher',
      status: apiModel.status ?? 'available',
      // Location and observation data from API
      observationId: apiModel.observationId ?? '',
      locationName: apiModel.locationName ?? '',
      latitude: apiModel.latitude ?? 0.0,
      longitude: apiModel.longitude ?? 0.0,
      // Gear and fishing data from API
      meshSize: apiModel.meshSize,
      gearLength: apiModel.gearLength,
      gearWidth: apiModel.gearWidth,
      gearNature: apiModel.gearNature,
      waterDepth: apiModel.waterDepth,
      fishingTime: apiModel.fishingTime,
      numberOfShrimps: apiModel.numberOfShrimps,
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
