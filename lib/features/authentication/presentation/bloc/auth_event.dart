import 'package:equatable/equatable.dart';

// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Event triggered when checking initial auth state
class CheckAuthStatus extends AuthEvent {}

// Event for email/password sign in
class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

// Event for email/password sign up
class SignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const SignUpWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

// Event for signing out
class SignOutRequested extends AuthEvent {}

// Event for password reset
class ResetPasswordRequested extends AuthEvent {
  final String email;

  const ResetPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
} 