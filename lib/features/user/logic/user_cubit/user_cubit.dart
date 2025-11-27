import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/domain/entities/review.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/exceptions/domain_exception.dart';
import 'package:siren_marketplace/core/domain/repositories/i_review_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_user_repository.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final IUserRepository userRepository;
  final IReviewRepository reviewRepository;

  UserCubit({required this.userRepository, required this.reviewRepository})
    : super(UserInitial());

  Future<void> loadPrimaryUser() async {
    emit(UserLoading());
    try {
      //we now have the UserRole.unknown enum value
      emit(const UserLoaded(null, UserRole.unknown));
    } catch (e) {
      emit(UserError('Failed to initialize user: ${e.toString()}'));
    }
  }

  Future<User?> loadById(String userId) async {
    emit(UserLoading());

    try {
      final user = await userRepository.getById(userId);
      if (user != null) {
        emit(UserLoaded(user, user.currentRole));
        return user;
      } else {
        emit(UserError('User not found'));
        return null;
      }
    } on DomainException catch (e) {
      emit(UserError(e.message));
      return null;
    } catch (e) {
      emit(UserError('Failed to load user: ${e.toString()}'));
      return null;
    }
  }

  Future<void> finalizeRoleSelection(UserRole role) async {
    emit(UserLoading());
    try {
      User? user;
      if (role == UserRole.fisher) {
        user = await userRepository.getFirstFisher();
      } else if (role == UserRole.buyer) {
        user = await userRepository.getFirstBuyer();
      }

      if (user != null) {
        emit(UserLoaded(user, role));
      } else {
        emit(
          UserError('Failed to load selected role: ${role.name} not found.'),
        );
      }
    } catch (e) {
      emit(UserError('Failed to finalize role selection: ${e.toString()}'));
    }
  }

  Future<void> loadUserRatings(String userId) async {
    try {
      final reviews = await reviewRepository.getReviewsForUser(userId);
      emit(UserRatingsLoaded(userId, reviews));
    } catch (e) {
      emit(UserError('Failed to load user ratings: ${e.toString()}'));
    }
  }

  User? getUserFromCache(String userId) {
    if (state is! UserLoaded) return null;
    return (state as UserLoaded).user;
  }
}
