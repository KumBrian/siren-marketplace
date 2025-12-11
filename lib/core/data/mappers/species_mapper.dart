import '../../domain/entities/species.dart';
import '../models/species_model.dart';

class SpeciesMapper {
  static Species toEntity(SpeciesModel model) {
    return Species(
      id: model.id,
      name: model.name,
      image: model.image,
      scientificName: model.scientificName,
      uid: model.uid,
    );
  }

  static SpeciesModel toModel(Species entity) {
    return SpeciesModel(
      id: entity.id,
      name: entity.name,
      image: entity.image,
      scientificName: entity.scientificName,
      uid: entity.uid,
    );
  }
}
