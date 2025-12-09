import 'package:equatable/equatable.dart';

class Species extends Equatable {
  final String id;
  final String name;
  final String image;
  final String scientificName;

  const Species({
    required this.id,
    required this.name,
    required this.image,
    this.scientificName = '',
  });

  @override
  List<Object?> get props => [id, name, image, scientificName];
}
