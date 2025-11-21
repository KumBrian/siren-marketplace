import '../../domain/entities/catch.dart';
import '../../domain/enums/catch_status.dart';
import '../../domain/value_objects/price.dart';
import '../../domain/value_objects/price_per_kg.dart';
import '../../domain/value_objects/weight.dart';
import '../models/catch_model.dart';
import 'species_mapper.dart';

class CatchMapper {
  /// Convert domain entity to data model
  static CatchModel toModel(Catch entity) {
    return CatchModel(
      id: entity.id,
      name: entity.name,
      datePosted: entity.datePosted.toIso8601String(),
      initialWeightGrams: entity.initialWeight.grams,
      availableWeightGrams: entity.availableWeight.grams,
      pricePerKgAmount: entity.pricePerKg.amountPerKg,
      totalPriceAmount: entity.totalPrice.amount,
      size: entity.size,
      market: entity.market,
      images: entity.images,
      species: SpeciesMapper.toModel(entity.species),
      fisherId: entity.fisherId,
      status: entity.status.name,
    );
  }

  /// Convert data model to domain entity
  static Catch toEntity(CatchModel model) {
    return Catch(
      id: model.id,
      name: model.name,
      datePosted: DateTime.parse(model.datePosted),
      initialWeight: Weight.fromGrams(model.initialWeightGrams),
      availableWeight: Weight.fromGrams(model.availableWeightGrams),
      pricePerKg: PricePerKg.fromAmount(model.pricePerKgAmount),
      totalPrice: Price.fromAmount(model.totalPriceAmount),
      size: model.size,
      market: model.market,
      images: model.images,
      species: SpeciesMapper.toEntity(model.species),
      fisherId: model.fisherId,
      status: _parseStatus(model.status),
    );
  }

  static CatchStatus _parseStatus(String status) {
    return CatchStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => CatchStatus.available,
    );
  }
}
