import '../api/models/product_api_models.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/species.dart';
import '../../domain/value_objects/price.dart';
import '../../domain/value_objects/price_per_kg.dart';
import '../../domain/value_objects/weight.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/value_objects/rating.dart';

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

    final product = Product(
      id: apiModel.id.toString(),
      name: apiModel.name ?? 'Product #${apiModel.id}',
      marketName:
          apiModel.market?.uid ??
          'Unknown Market', // Adjust based on actual data
      status: apiModel.status ?? 'unknown',
      pricePerKg: PricePerKg.fromAmount((apiModel.pricePerKg ?? 0).toInt()),
      totalPrice: Price.fromAmount((apiModel.finalPrice ?? 0).toInt()),
      initialWeight: Weight.fromGrams((apiModel.initialWeight ?? 0).toInt()),
      availableWeight: Weight.fromGrams(
        (apiModel.availableWeight ?? 0).toInt(),
      ),
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
      fisherId: apiModel.account?.id?.toString() ?? apiModel.account?.uid ?? '',
      fisher: apiModel.account != null
          ? User(
              id:
                  apiModel.account!.id?.toString() ??
                  apiModel.account!.uid ??
                  '',
              name:
                  '${apiModel.account!.firstName ?? ''} ${apiModel.account!.lastName ?? ''}'
                      .trim()
                      .isEmpty
                  ? (apiModel.account!.uid ?? 'Unknown')
                  : '${apiModel.account!.firstName ?? ''} ${apiModel.account!.lastName ?? ''}'
                        .trim(),
              rating: Rating.fromValue(
                apiModel.account!.rating ?? 0.0,
              ), // Assuming rating field exists or similar
              reviewCount: apiModel.account!.totalReviews ?? 0,
              avatarUrl: apiModel.account!.avatar,
              currentRole: UserRole.fisher,
            )
          : null,
    );

    print(
      'DEBUG ProductMapper - Product ${product.id}: API offersCount = ${apiModel.offersCount}',
    );

    return product;
  }
}
