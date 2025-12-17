import 'package:equatable/equatable.dart';

/// Represents a subgroup of species (e.g., "Shrimp")
class Subgroup extends Equatable {
  final String name;
  final String description;
  final List<SubgroupSpecies> species;

  const Subgroup({
    required this.name,
    required this.description,
    required this.species,
  });

  @override
  List<Object?> get props => [name, description, species];
}

/// Represents a species within a subgroup
class SubgroupSpecies extends Equatable {
  final int id;
  final String name;
  final String imageUrl;

  const SubgroupSpecies({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, imageUrl];
}
