import 'package:siren_marketplace/core/data/persistence/species_entity.dart';

abstract class SpeciesDataSource {
  Future<void> insertSpecies(SpeciesEntity entity);

  Future<SpeciesEntity?> getSpeciesById(String id);

  Future<List<SpeciesEntity>> getAllSpecies();

  Future<void> updateSpecies(SpeciesEntity entity);

  Future<void> deleteSpecies(String id);
}
