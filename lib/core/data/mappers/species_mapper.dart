import '../../domain/entities/species.dart';
import '../models/species_model.dart';

class SpeciesMapper {
  static SpeciesModel toModel(Species entity) {
    return SpeciesModel(
      id: entity.id,
      name: entity.name,
      scientificName: entity.scientificName,
    );
  }

  static Species toEntity(SpeciesModel model) {
    return Species(
      id: model.id,
      name: model.name,
      scientificName: model.scientificName,
    );
  }
}
