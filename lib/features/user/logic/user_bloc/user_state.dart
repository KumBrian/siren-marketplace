part of "user_bloc.dart";

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {} // New initial state for clarity

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final AppUser? user;
  final Role role;

  const UserLoaded(this.user, this.role);

  @override
  List<Object> get props => [?user, role];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}

class UserRatingsLoaded extends UserState {
  final String userId;
  final List<Map<String, dynamic>> ratings;

  const UserRatingsLoaded(this.userId, this.ratings);

  @override
  List<Object> get props => [userId, ratings];
}
