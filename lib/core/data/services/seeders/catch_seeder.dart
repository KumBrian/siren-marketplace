import 'dart:math';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/species.dart';
import 'package:siren_marketplace/core/data/mappers/species_mapper.dart';
import 'package:siren_marketplace/core/domain/enums/catch_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/price_per_kg.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import 'package:uuid/uuid.dart';
import 'seeder_data.dart';

class CatchSeeder {
  final Uuid _uuid = const Uuid();
  final Random _rng = Random();

  static final List<Species> _speciesList = SeederData.speciesList
      .map((model) => SpeciesMapper.toEntity(model))
      .toList();

  /// Generates a random weight in grams with 0.1kg (100g) steps.
  /// maxKg is inclusive maximum kg (e.g. 100 -> up to 100.0 kg).
  int generateWeightGramsOneDecimal(int maxKg) {
    final steps = maxKg * 10; // number of 0.1kg steps
    final step = _rng.nextInt(steps + 1); // 0..steps
    return step * 100; // step * 0.1kg -> grams
  }

  Future<List<Catch>> seed() async {
    final repository = sl<ICatchRepository>();
    final existing = await repository.getAvailableCatches();
    if (existing.isNotEmpty) {
      print('Catches exist. Returning existing.');
      return existing;
    }

    final List<Catch> seeded = [];
    final now = DateTime.now();

    final List<String> fisherIds = SeederData.userMaps
        .where((user) => user['role'] == UserRole.fisher)
        .map((user) => user['id'] as String)
        .toList();

    for (int i = 0; i < 15; i++) {
      final species = _speciesList[i % _speciesList.length];

      // Weight stored as grams (integer)
      final int initialWeightGrams = generateWeightGramsOneDecimal(100);

      // pricePerKg remains integer (e.g. 1989)
      final int pricePerKg = 500 + _rng.nextInt(2000);

      final String market = SeederData.markets[i % SeederData.markets.length];

      final fisherId = fisherIds[_rng.nextInt(fisherIds.length)];

      CatchStatus status;
      int availableWeightGrams = initialWeightGrams;
      if (i < 3) {
        status = CatchStatus.available;
      } else if (i < 5) {
        status = CatchStatus.expired;
        // half the weight (integer arithmetic) — round down to nearest 100g
        availableWeightGrams = (initialWeightGrams * 50) ~/ 100;
        // normalize to 100g steps
        availableWeightGrams = (availableWeightGrams / 100).floor() * 100;
      } else if (i == 14) {
        status = CatchStatus.soldOut;
        availableWeightGrams = 0;
      } else {
        status = CatchStatus.available;
      }

      // Use species image as the only catch image
      final List<String> catchImages = [species.image];

      // total price computed in integer arithmetic: (grams * pricePerKg) / 1000
      final int totalPrice = (initialWeightGrams * pricePerKg) ~/ 1000;

      final c = Catch(
        id: _uuid.v4(),
        name: species.name,
        datePosted: now.subtract(Duration(hours: i * 5)),
        // new grams fields
        initialWeight: Weight.fromGrams(initialWeightGrams),
        availableWeight: Weight.fromGrams(availableWeightGrams),
        pricePerKg: PricePerKg.fromAmount(pricePerKg),
        totalPrice: Price.fromAmount(totalPrice),
        size: species.id == "prawn"
            ? ['Large', 'Medium', 'Small'][_rng.nextInt(3)]
            : ['0', '00', '000'][_rng.nextInt(3)],
        market: market,
        species: species,
        fisherId: fisherId,
        images: catchImages,
        status: status,
        observationId: 'Obs-${(i + 1).toString().padLeft(3, '0')}',
        locationName: const [
          'Douala Port',
          'Limbe Coast',
          'Kribi Beach',
          'Wouri River',
        ][_rng.nextInt(4)],
        latitude: 4.0511 + (_rng.nextDouble() * 0.1),
        longitude: 9.7679 + (_rng.nextDouble() * 0.1),
        meshSize: 2.5 + _rng.nextInt(3),
      );

      await repository.create(c);
      seeded.add(c);
    }

    print('${seeded.length} catches seeded.');
    return seeded;
  }
}
