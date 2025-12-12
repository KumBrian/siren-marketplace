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

    // Weights are now in grams from API (no conversion needed)
    final initialWeightGrams = (apiModel.estimatedWeightInGrams ?? 0).toInt();
    final publishedWeightGrams = (apiModel.publishedWeightInGrams ?? 0).toInt();

    // Convert price_per_kg to cents
    final pricePerKgCents = ((apiModel.pricePerKg ?? 0) * 100).toInt();
    final finalPriceCents = ((apiModel.finalPrice ?? 0) * 100).toInt();

    // Determine status from published_in_market_place flag
    // If publishedInMarketPlace is true, status is 'available', else use API status or default to 'draft'
    String determineStatus() {
      if (apiModel.publishedInMarketPlace == true) {
        return 'available';
      }
      // Use API status if provided, otherwise default to 'draft'
      return apiModel.status?.toLowerCase() ?? 'draft';
    }

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
          (apiModel.specie != null
              ? SpeciesModel(
                  id: apiModel.specie!.uid,
                  name:
                      apiModel.specie!.uid, // Display uid if species not in app
                  image: '',
                  uid: apiModel.specie!.uid,
                )
              : const SpeciesModel(
                  id: 'unknown',
                  name: 'Unknown',
                  image: '',
                  uid: '',
                )),
      fisherId: apiModel.account?.id?.toString() ?? 'unknown_fisher',
      status: determineStatus(),
      // Location and observation data from API
      observationId: apiModel.observationId ?? '',
      locationName: '', // Not provided by API yet
      latitude: 0.0, // Backend doesn't send coords yet
      longitude: 0.0, // Backend doesn't send coords yet
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

  /// Map domain CatchModel to API CreateCatchRequest
  /// imageUrls should be the storageFilePath values from Pulsebox upload
  static CreateCatchRequest toCreateRequest(
    CatchModel model, {
    required List<String> imageUrls,
  }) {
    // Only include selling data if catch is available for sale
    final isForSale = model.status == 'available';

    return CreateCatchRequest(
      specie: model.species.uid, // Use UUID from backend!
      subgroup: model.species.uid, // Use same UUID for subgroup
      gearMeshSizeInFinger: model.meshSize ?? 0.0,
      gearLengthInMeter: model.gearLength ?? 0.0,
      gearNature: model.gearNature ?? 'Unknown',
      waterDepthInMeter: model.waterDepth ?? 0.0,
      fishingTimeInHour: model.fishingTime ?? 0.0,
      estimatedWeightInKg: model.initialWeightGrams / 1000.0,
      averageSizeInCm: double.tryParse(model.size) ?? 0.0,
      estimatedSize: model.numberOfShrimps ?? 0,
      // Only send selling data when catch is for sale
      publishedWeightInKg: isForSale
          ? (model.availableWeightGrams / 1000.0)
          : 0.0,
      pricePerKg: isForSale ? (model.pricePerKgAmount / 100.0) : 0.0,
      finalPrice: isForSale ? (model.totalPriceAmount / 100.0) : 0.0,
      publishedInMarketPlace: isForSale,
      note: '', // API expects empty string, not null
      images: imageUrls.map((url) => CatchImageRequest(mediaUrl: url)).toList(),
      alpha: '', // API expects empty string, not null
      dead: false,
      coordX: model.longitude,
      coordY: model.latitude,
      date: DateTime.now().toIso8601String(),
      market: 1, // Always 1 for now per user
      observationType: '', // API expects empty string, not null
      patrol: '', // API expects empty string, not null
      segment: '', // API expects empty string, not null
    );
  }
}
