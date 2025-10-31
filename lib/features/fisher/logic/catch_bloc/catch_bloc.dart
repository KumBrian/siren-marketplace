import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/features/fisher/data/catch_repository.dart';

part 'catch_event.dart';
part 'catch_state.dart';

class CatchesBloc extends Bloc<CatchesEvent, CatchesState> {
  final CatchRepository repository;

  CatchesBloc(this.repository) : super(CatchesInitial()) {
    on<LoadCatches>(_onLoadCatches);
    on<LoadCatchesByFisher>(_onLoadCatchesByFisher);
    on<AddCatch>(_onAddCatch);
    on<UpdateCatchEvent>(_onUpdateCatch);
    on<DeleteCatchEvent>(_onDeleteCatch);
  }

  Future<List<Catch>> _assembleCatches(
    List<Map<String, dynamic>> catchMaps,
  ) async {
    return Future.wait(
      catchMaps.map((m) async {
        final catchId = m['catch_id'] as String;
        final offerMaps = await repository.dbHelper.getOfferMapsByCatchId(
          catchId,
        );
        final offers = offerMaps.map((o) => Offer.fromMap(o)).toList();
        return Catch.fromMap(m).copyWith(offers: offers);
      }),
    );
  }

  Future<void> _onLoadCatches(
    LoadCatches event,
    Emitter<CatchesState> emit,
  ) async {
    emit(CatchesLoading());
    try {
      final catchMaps = await repository.getAllCatchMaps();
      final catches = await _assembleCatches(catchMaps);
      emit(CatchesLoaded(catches));
    } catch (e) {
      emit(CatchesError('Failed to load catches: $e'));
    }
  }

  Future<void> _onLoadCatchesByFisher(
    LoadCatchesByFisher event,
    Emitter<CatchesState> emit,
  ) async {
    emit(CatchesLoading());
    try {
      final catchMaps = await repository.getCatchMapsByFisherId(event.fisherId);
      final catches = await _assembleCatches(catchMaps);
      emit(CatchesLoaded(catches));
    } catch (e) {
      emit(CatchesError('Failed to load catches for fisher: $e'));
    }
  }

  Future<void> _onAddCatch(AddCatch event, Emitter<CatchesState> emit) async {
    try {
      await repository.insertCatch(event.catchModel);
      final updatedCatchMaps = await repository.getAllCatchMaps();
      final updatedCatches = await _assembleCatches(updatedCatchMaps);
      emit(CatchesLoaded(updatedCatches));
    } catch (e) {
      emit(CatchesError('Failed to add catch: $e'));
    }
  }

  Future<void> _onUpdateCatch(
    UpdateCatchEvent event,
    Emitter<CatchesState> emit,
  ) async {
    try {
      await repository.updateCatch(event.catchModel);
      final updatedCatchMaps = await repository.getAllCatchMaps();
      final updatedCatches = await _assembleCatches(updatedCatchMaps);
      emit(CatchesLoaded(updatedCatches));
    } catch (e) {
      emit(CatchesError('Failed to update catch: $e'));
    }
  }

  // 🔹 Delete catch
  Future<void> _onDeleteCatch(
    DeleteCatchEvent event,
    Emitter<CatchesState> emit,
  ) async {
    try {
      // 1. Perform the soft delete (update status to 'removed')
      await repository.removeCatchFromMarketplace(event.catchId);
      emit(CatchDeletedSuccess());

      // 2. Re-fetch only the catches belonging to the fisherman whose item was removed.
      // This assumes the BLoC instance needs to know the fisherId to reload correctly.
      // If you don't have the fisherId here, you *must* rely on event state or context.

      // Assuming you can get the fisherId or we reload all and filter.
      // Sticking to your original pattern (reload all) but fixing the UI filter:

      final updatedCatchMaps = await repository.getAllCatchMaps();
      final updatedCatches = await _assembleCatches(updatedCatchMaps);
      final marketCatches = updatedCatches
          .where(
            (c) =>
                c.status != CatchStatus.removed &&
                c.status != CatchStatus.expired,
          )
          .toList();
      emit(CatchesLoaded(marketCatches));
    } catch (e) {
      emit(CatchesError('Failed to delete catch: $e'));
    }
  }
}
