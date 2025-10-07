import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/bloc/cubits/species_filter_cubit/species_filter_state.dart';

class SpeciesFilterCubit extends Cubit<SpeciesFilterState> {
  SpeciesFilterCubit() : super(const SpeciesFilterState());

  void toggleSpecies(String status) {
    emit(SpeciesFilterState(selectedSpecies: status));
  }

  void clear() {
    emit(const SpeciesFilterState());
  }
}
