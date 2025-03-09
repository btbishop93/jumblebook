import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Check current auth state
final class CheckAuthStatus extends AuthEvent {}

// Email & Password Authentication
final class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

final class SignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const SignUpWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

// Social Authentication
final class SignInWithGoogleRequested extends AuthEvent {}

final class SignInWithAppleRequested extends AuthEvent {}

// Anonymous Authentication
final class SignInAnonymouslyRequested extends AuthEvent {}

// Sign Out
final class SignOutRequested extends AuthEvent {}

// Password Reset
final class ResetPasswordRequested extends AuthEvent {
  final String email;

  const ResetPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

// Account Management
final class DeleteAccountRequested extends AuthEvent {}

final class ReauthenticateAndDeleteAccountRequested extends AuthEvent {
  final String email;
  final String password;

  const ReauthenticateAndDeleteAccountRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
