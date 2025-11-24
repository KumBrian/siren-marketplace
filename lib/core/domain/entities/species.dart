import 'package:equatable/equatable.dart';

class Species extends Equatable {
  final String id;
  final String name;
  final String? scientificName;

  const Species({required this.id, required this.name, this.scientificName});

  @override
  List<Object?> get props => [id, name, scientificName];
}
