import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/models/app_user.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/features/buyer/data/models/buyer.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<LoadPrimaryUser>(_onLoadPrimaryUser);
    on<FinalizeRoleSelection>(_onFinalizeRoleSelection);

    // 🌟 NEW HANDLER 🌟
    on<LoadUserRatings>(_onLoadUserRatings);
  }

  // --- Helper function to assemble the user model ---
  Fisher _assembleFisher(Map<String, dynamic> userMap) {
    final fisher = Fisher.fromMap(userMap);
    return fisher;
  }

  Buyer _assembleBuyer(Map<String, dynamic> userMap) {
    final buyer = Buyer.fromMap(userMap);
    return buyer;
  }

  // ----------------------------------------------------------------------
  // Handler for LoadPrimaryUser (Initial App Start)
  // ----------------------------------------------------------------------
  Future<void> _onLoadPrimaryUser(
    LoadPrimaryUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      // Always start as unknown unless explicitly finalized
      emit(const UserLoaded(null, Role.unknown));
    } catch (e) {
      emit(UserError('Failed to initialize user: ${e.toString()}'));
    }
  }

  // ----------------------------------------------------------------------
  // Handler for FinalizeRoleSelection
  // ----------------------------------------------------------------------
  Future<void> _onFinalizeRoleSelection(
    FinalizeRoleSelection event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      if (event.selectedRole == Role.fisher) {
        final fisherMap = await userRepository.getFirstFisherMap();
        if (fisherMap != null) {
          final fisher = _assembleFisher(fisherMap);
          emit(UserLoaded(fisher, Role.fisher));
          return;
        }
      } else if (event.selectedRole == Role.buyer) {
        final buyerMap = await userRepository.getFirstBuyerMap();
        if (buyerMap != null) {
          final buyer = _assembleBuyer(buyerMap);
          emit(UserLoaded(buyer, Role.buyer));
          return;
        }
      }

      // If selection fails (e.g., user was deleted), emit an error.
      emit(
        UserError(
          'Failed to load selected role: ${event.selectedRole.name} not found.',
        ),
      );
    } catch (e) {
      emit(UserError('Failed to finalize role selection: ${e.toString()}'));
    }
  }

  // ----------------------------------------------------------------------
  // 🌟 NEW: Handler for LoadUserRatings
  // ----------------------------------------------------------------------
  Future<void> _onLoadUserRatings(
    LoadUserRatings event,
    Emitter<UserState> emit,
  ) async {
    // Keep the current UserLoaded state active if possible, only emit loading
    // for the ratings section, or only emit the new state.
    // For simplicity, we'll emit the dedicated state.

    // NOTE: If you need to refresh the user profile *after* loading ratings,
    // you would dispatch another LoadPrimaryUser/FinalizeRoleSelection event.

    try {
      final ratings = await userRepository.getRatingsReceivedByUserId(
        event.userId,
      );

      // We also need the rater's name and avatar, but for now, we'll just return the raw maps.
      // In a real app, you might join this data or fetch rater details here.

      emit(UserRatingsLoaded(event.userId, ratings));
    } catch (e) {
      // If loading ratings fails, we don't want to lose the primary user state.
      // A better pattern for this would be a separate RatingsBloc, but we'll
      // handle the error gracefully here.
      debugPrint('Error loading user ratings: ${e.toString()}');
      // Re-emit the last known user state if we can, or just emit an error.
      // We will just emit an error specific to this action for now.
      emit(UserError('Failed to load user ratings: ${e.toString()}'));
    }
  }
}
