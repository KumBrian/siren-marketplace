part of "user_bloc.dart";

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadPrimaryUser extends UserEvent {
  const LoadPrimaryUser();
}

class FinalizeRoleSelection extends UserEvent {
  final Role selectedRole;

  const FinalizeRoleSelection(this.selectedRole);

  @override
  List<Object> get props => [selectedRole];
}

class LoadUserRatings extends UserEvent {
  final String userId;

  const LoadUserRatings(this.userId);

  @override
  List<Object> get props => [userId];
}
