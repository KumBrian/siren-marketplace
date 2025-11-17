import 'package:equatable/equatable.dart';

class Species extends Equatable {
  final String id;
  final String name;

  const Species({required this.id, required this.name});

  @override
  List<Object> get props => [id, name];
}
