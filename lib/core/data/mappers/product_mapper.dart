import '../../domain/entities/product.dart';
import '../../domain/entities/species.dart';
import '../../domain/value_objects/price.dart';
import '../../domain/value_objects/price_per_kg.dart';
import '../../domain/value_objects/weight.dart';
import '../api/models/product_api_models.dart';

class ProductMapper {
  static Product toDomain(ProductApiModel apiModel) {
    // Map status from API to domain (Available, Sold, etc.)
    // Note: API returns "available" string, need to match logic if necessary.
    // For now, passing string directly or we could check against enum.

    // Weights
    final initialWeight = Weight.fromKg(apiModel.initialWeight ?? 0.0);
    final availableWeightKg = (apiModel.publishedWeightInGrams ?? 0.0) / 1000.0;
    final availableWeight = Weight.fromKg(availableWeightKg);

    // Prices
    // Note: API might send price as raw amount or something else.
    // User JSON shows "price_per_kg": 0, "final_price": 0.
    // Let's assume these are currency amounts.
    final pricePerKg = PricePerKg.fromAmount(
      (apiModel.pricePerKg ?? 0).toInt(),
    );
    final totalPrice = Price.fromAmount((apiModel.finalPrice ?? 0).toInt());

    // Species
    // Simplified mapping since we don't have full species object in ProductApiModel yet
    // Need to safeguard against nulls
    final speciesId = apiModel.specie?.uid ?? 'unknown';

    return Product(
      id: apiModel.id.toString(),
      name: apiModel.name ?? 'Product #${apiModel.id}',
      marketName: 'Market', // Placeholder or parse from apiModel.market
      status: apiModel.status ?? 'unknown',
      pricePerKg: pricePerKg,
      totalPrice: totalPrice,
      initialWeight: initialWeight,
      availableWeight: availableWeight,
      size: apiModel.size ?? 'Unknown',
      datePosted:
          DateTime.tryParse(apiModel.datePosted ?? '') ?? DateTime.now(),
      locationName: apiModel.locationName ?? '',
      latitude: apiModel.latitude ?? 0.0,
      longitude: apiModel.longitude ?? 0.0,
      soldAt: apiModel.soldAt != null
          ? DateTime.tryParse(apiModel.soldAt!)
          : null,
      isSold: apiModel.isSold ?? false,
      meshSize: apiModel.gearMeshSizeInFinger,
      gearLength: apiModel.gearLengthInMeter,
      gearWidth: apiModel.gearWidthInMeter,
      gearNature: apiModel.gearNature,
      species: Species(
        id: speciesId,
        name: apiModel.specie?.name ?? 'Species $speciesId',
        image: apiModel.specie?.image ?? '',
        uid: speciesId,
        scientificName: '',
      ),
    );
  }
}
