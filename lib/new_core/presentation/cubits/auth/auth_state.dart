import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/enums/user_role.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  final UserRole currentRole;

  const AuthAuthenticated({required this.user, required this.currentRole});

  @override
  List<Object?> get props => [user, currentRole];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
