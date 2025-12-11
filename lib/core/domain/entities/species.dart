import 'package:equatable/equatable.dart';

class Species extends Equatable {
  final String id; // slug for backward compatibility
  final String uid; // UUID from backend
  final String name;
  final String image;
  final String scientificName;

  const Species({
    required this.id,
    required this.uid,
    required this.name,
    required this.image,
    this.scientificName = '',
  });

  @override
  List<Object?> get props => [id, uid, name, image, scientificName];
}
