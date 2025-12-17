import '../../domain/entities/subgroup.dart';
import '../../utils/species_image_mapper.dart';
import '../api/models/subgroup_api_models.dart';

/// Mapper for converting subgroup API models to domain entities
class SubgroupMapper {
  /// Convert SubgroupModel to Subgroup domain entity
  static Subgroup toDomain(SubgroupModel apiModel) {
    return Subgroup(
      name: apiModel.name,
      description: apiModel.description,
      species: apiModel.species.map(_speciesToDomain).toList(),
    );
  }

  /// Convert SubgroupSpeciesModel to SubgroupSpecies domain entity
  static SubgroupSpecies _speciesToDomain(SubgroupSpeciesModel apiModel) {
    // Use local image mapping if API imageUrl is empty
    final imageUrl = apiModel.imageUrl.isEmpty
        ? SpeciesImageMapper.getImagePath(apiModel.name)
        : apiModel.imageUrl;

    return SubgroupSpecies(
      id: apiModel.id,
      name: apiModel.name,
      imageUrl: imageUrl,
    );
  }

  /// Convert list of SubgroupModels to list of Subgroups
  static List<Subgroup> toDomainList(List<SubgroupModel> apiModels) {
    return apiModels.map(toDomain).toList();
  }
}
