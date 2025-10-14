import 'package:equatable/equatable.dart';
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
    // ⚠️ REMOVED: on<SwitchToFisher>(...) and on<SwitchToBuyer>(...)
    on<FinalizeRoleSelection>(_onFinalizeRoleSelection);
  }

  // --- Helper function to assemble the user model ---
  // ... (Fisher and Buyer assembly methods remain the same)
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
  // Future<void> _onLoadPrimaryUser(
  //   LoadPrimaryUser event,
  //   Emitter<UserState> emit,
  // ) async {
  //   emit(UserLoading());
  //   try {
  //     final fisherMap = await userRepository.getFirstFisherMap();
  //
  //     if (fisherMap != null) {
  //       final fisher = _assembleFisher(fisherMap);
  //       emit(UserLoaded(fisher, Role.fisher));
  //       return;
  //     }
  //
  //     final buyerMap = await userRepository.getFirstBuyerMap();
  //
  //     if (buyerMap != null) {
  //       final buyer = _assembleBuyer(buyerMap);
  //       emit(UserLoaded(buyer, Role.buyer));
  //       return;
  //     }
  //
  //     emit(
  //       const UserError(
  //         'No Fisher or Buyer found in the database. Run Seeder.',
  //       ),
  //     );
  //   } catch (e) {
  //     emit(UserError('Failed to load primary user profile: ${e.toString()}'));
  //   }
  // }

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
  // ✅ NEW: Handler for FinalizeRoleSelection
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
}
