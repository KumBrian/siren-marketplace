import '../api/models/catch_api_models.dart';
import '../models/catch_model.dart';
import '../models/species_model.dart';
import '../../domain/entities/species.dart';

class CatchApiMapper {
  static CatchModel toDomain(
    CatchApiModel apiModel, {
    List<Species>? speciesList,
  }) {
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

    // Get species by uid lookup
    SpeciesModel getSpecies() {
      // First check legacy species field
      if (apiModel.species != null) {
        return apiModel.species!;
      }

      // First, try to use the specie data directly from the API response
      if (apiModel.specie != null) {
        final specieData = apiModel.specie!;

        // If the API provides id and name directly, use them
        if (specieData.id != null && specieData.name != null) {
          return SpeciesModel(
            id: specieData.id.toString(),
            uid: specieData.uid,
            name: specieData.name!,
            image: '', // Will be mapped from local assets based on name
          );
        }
      }

      // Fallback: Try to match by UID from cached species list
      if (apiModel.specie?.uid != null &&
          speciesList != null &&
          speciesList.isNotEmpty) {
        try {
          final matchedSpecies = speciesList.firstWhere(
            (s) => s.uid == apiModel.specie!.uid,
          );
          return SpeciesModel(
            id: matchedSpecies.id,
            uid: matchedSpecies.uid,
            name: matchedSpecies.name,
            image: matchedSpecies.image,
            scientificName: matchedSpecies.scientificName,
          );
        } catch (_) {
          // Species not found in list, continue to fallback
        }
      }

      // Fallback: use uid as name if species not found
      if (apiModel.specie?.uid != null) {
        return SpeciesModel(
          id: apiModel.specie!.uid,
          name: apiModel.specie!.name ?? apiModel.specie!.uid,
          image: '',
          uid: apiModel.specie!.uid,
        );
      }

      // No species data at all
      return const SpeciesModel(
        id: 'unknown',
        name: 'Unknown',
        image: '',
        uid: '',
      );
    }

    return CatchModel(
      id: apiModel.id.toString(),
      name: apiModel.name ?? getSpecies().name ?? 'Catch #${apiModel.id}',
      datePosted: apiModel.createdAt ?? DateTime.now().toIso8601String(),
      initialWeightGrams: initialWeightGrams,
      availableWeightGrams: publishedWeightGrams,
      pricePerKgAmount: pricePerKgCents,
      totalPriceAmount: finalPriceCents,
      size: apiModel.averageSizeInCm?.toString() ?? 'Unknown',
      market: apiModel.market ?? 'Unknown Market',
      images: images,
      species: getSpecies(),
      fisherId: apiModel.account?.id?.toString() ?? 'unknown_fisher',
      status: determineStatus(),
      // Location and observation data from API
      observationId: apiModel.observationId ?? '',
      locationName: apiModel.locationName ?? '',
      latitude: apiModel.latitude ?? 0.0,
      longitude: apiModel.longitude ?? 0.0,
      // Gear and fishing data from API
      meshSize: apiModel.gear?.gearMeshSizeInFinger,
      gearLength: apiModel.gear?.gearLengthInMeter,
      gearWidth: apiModel.gear?.gearWidthInMeter,
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
      specie: int.tryParse(model.species.id) ?? 1, // Convert species ID to int
      gearMeshSizeInFinger: model.meshSize ?? 0.0,
      gearLengthInMeter: model.gearLength ?? 0.0,
      gearWidthInMeter: model.gearWidth ?? 0.0,
      gearNature: model.gearNature ?? 'Unknown',
      waterDepthInMeter: model.waterDepth ?? 0.0,
      fishingTimeInHour: model.fishingTime ?? 0.0,
      estimatedWeightInGrams: model.initialWeightGrams
          .toDouble(), // Send in grams
      averageSizeInCm: double.tryParse(model.size) ?? 0.0,
      estimatedSize: model.numberOfShrimps ?? 0,
      // Only send selling data when catch is for sale
      publishedWeightInGrams: isForSale
          ? model.availableWeightGrams
                .toDouble() // Send in grams
          : 0.0,
      pricePerKg: isForSale ? (model.pricePerKgAmount / 100.0) : 0.0,
      finalPrice: isForSale ? (model.totalPriceAmount / 100.0) : 0.0,
      publishedInMarketPlace: isForSale,
      note: '', // API expects empty string, not null
      images: imageUrls.map((url) => CatchImageRequest(mediaUrl: url)).toList(),
      alpha: '', // API expects empty string, not null
      size: model.size,
      dead: false,
      locationName: model.locationName,
      latitude: model.latitude,
      longitude: model.longitude,
      date: DateTime.now().toIso8601String(),
      market: 1, // Always 1 for now per user
      observationType: '', // API expects empty string, not null
      patrol: '', // API expects empty string, not null
      segment: '', // API expects empty string, not null
    );
  }

  /// Map domain CatchModel to API Update Request body (Partial)
  static Map<String, dynamic> toUpdateRequest(CatchModel model) {
    return {
      'publishedInMarketPlace': model.status == 'available',
      'pricePerKg': (model.pricePerKgAmount / 100.0),
      'publishedWeightInGrams': model.availableWeightGrams.toDouble(),
      'finalPrice': (model.totalPriceAmount / 100.0),
      'status': model.status == 'available' ? 'PUBLISHED' : 'UPLOADED',
    };
  }
}
