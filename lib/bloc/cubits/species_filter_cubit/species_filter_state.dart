import 'package:equatable/equatable.dart';

class SpeciesFilterState extends Equatable {
  final String selectedSpecies;

  const SpeciesFilterState({this.selectedSpecies = ""});

  SpeciesFilterState copyWith({String? selectedSpecies}) {
    return SpeciesFilterState(
      selectedSpecies: selectedSpecies ?? this.selectedSpecies,
    );
  }

  @override
  List<Object?> get props => [selectedSpecies];
}
