import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/exceptions/domain_exception.dart';
import 'package:siren_marketplace/core/domain/exceptions/not_found_exception.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';

part 'catches_state.dart';

class CatchesCubit extends Cubit<CatchesState> {
  final ICatchRepository repository;

  CatchesCubit({required this.repository}) : super(const CatchesState());

  /// Load all catches for a fisher
  Future<void> loadForFisher(String fisherId) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final results = await repository.getByFisherId(fisherId);
      emit(state.copyWith(loading: false, catches: results));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to load catches: ${e.toString()}',
        ),
      );
    }
  }

  /// Load a single catch by ID
  Future<Catch?> loadById(String catchId) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final catchItem = await repository.getById(catchId);

      // Update the catches list with this single catch
      emit(state.copyWith(loading: false, catches: [catchItem!]));
      return catchItem;
    } on NotFoundException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return null;
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
      return null;
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to load catch: ${e.toString()}',
        ),
      );
    }
    return null;
  }

  /// Load multiple catches by IDs
  Future<void> loadRange(List<String> catchIds) async {
    if (catchIds.isEmpty) return;

    emit(state.copyWith(loading: true, error: null));

    try {
      final List<Catch> results = [];
      // Note: In a real app, we should have a repository method for this
      // to avoid N+1 queries. For now, we loop.
      for (final id in catchIds) {
        // Check if already in cache to avoid redundant calls?
        // For now, refresh all to ensure up-to-date data.
        final item = await repository.getById(id);
        if (item != null) {
          results.add(item);
        }
      }

      emit(state.copyWith(loading: false, catches: results));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to load catches: ${e.toString()}',
        ),
      );
    }
  }

  /// Update an existing catch
  Future<void> updateCatch(Catch catchItem) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      await repository.update(catchItem);

      final results = await repository.getByFisherId(catchItem.fisherId);
      emit(state.copyWith(loading: false, catches: results));
    } on NotFoundException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to update catch: ${e.toString()}',
        ),
      );
    }
  }

  /// Delete a catch
  Future<void> deleteCatch(String catchId, String fisherId) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      await repository.delete(catchId);
      final results = await repository.getByFisherId(fisherId);
      emit(state.copyWith(loading: false, catches: results));
    } on NotFoundException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to delete catch: ${e.toString()}',
        ),
      );
    }
  }

  /// Create a new catch
  Future<void> createCatch(Catch catchItem) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      await repository.create(catchItem);
      final results = await repository.getByFisherId(catchItem.fisherId);
      emit(state.copyWith(loading: false, catches: results));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to create catch: ${e.toString()}',
        ),
      );
    }
  }

  /// Load all available catches on the marketplace (for buyers)
  Future<void> loadAvailableCatches() async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final results = await repository.getAvailableCatches();
      emit(state.copyWith(loading: false, catches: results));
    } on DomainException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Failed to load marketplace catches: ${e.toString()}',
        ),
      );
    }
  }

  /// Get a catch from the current state cache
  Catch? getCatchFromCache(String catchId) {
    try {
      return state.catches.firstWhere((c) => c.id == catchId);
    } catch (_) {
      return null;
    }
  }
}
