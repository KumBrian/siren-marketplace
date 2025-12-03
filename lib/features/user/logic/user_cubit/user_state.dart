part of 'user_cubit.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User? user;
  final UserRole role;

  const UserLoaded(this.user, this.role);

  @override
  List<Object?> get props => [user, role];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserRatingsLoaded extends UserState {
  final String userId;
  final List<Review> ratings;

  const UserRatingsLoaded(this.userId, this.ratings);

  @override
  List<Object?> get props => [userId, ratings];
}
