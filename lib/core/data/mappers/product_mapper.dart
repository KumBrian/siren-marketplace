import '../api/models/product_api_models.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/species.dart';
import '../../domain/value_objects/price.dart';
import '../../domain/value_objects/price_per_kg.dart';
import '../../domain/value_objects/weight.dart';

class ProductMapper {
  static Product toDomain(
    ProductApiModel apiModel, [
    List<Species> speciesList = const [],
  ]) {
    // Helper to find species
    Species getSpecies() {
      if (apiModel.specie != null) {
        if (apiModel.specie!.uid != null && speciesList.isNotEmpty) {
          try {
            return speciesList.firstWhere((s) => s.uid == apiModel.specie!.uid);
          } catch (_) {}
        }

        return Species(
          id: apiModel.specie!.uid ?? 'unknown',
          name: apiModel.specie!.name ?? 'Unknown',
          image: apiModel.specie!.image ?? '',
          uid: apiModel.specie!.uid ?? '',
        );
      }
      return const Species(id: 'unknown', name: 'Unknown', image: '', uid: '');
    }

    return Product(
      id: apiModel.id.toString(),
      name: apiModel.name ?? 'Product #${apiModel.id}',
      marketName:
          apiModel.market?.uid ??
          'Unknown Market', // Adjust based on actual data
      status: apiModel.status ?? 'unknown',
      pricePerKg: PricePerKg.fromAmount(
        ((apiModel.pricePerKg ?? 0) * 100).toInt(),
      ),
      totalPrice: Price.fromAmount(((apiModel.finalPrice ?? 0) * 100).toInt()),
      initialWeight: Weight.fromKg(apiModel.initialWeight ?? 0),
      availableWeight: Weight.fromKg(apiModel.availableWeight ?? 0),
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
      gearNature: apiModel.gearNature,
      species: getSpecies(),
      offersCount: apiModel.offersCount,
      images: apiModel.images,
      fisherId: apiModel.account?.uid ?? '',
    );
  }
}
