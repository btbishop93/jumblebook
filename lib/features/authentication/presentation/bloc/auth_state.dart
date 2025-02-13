import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import 'auth_data.dart';

// Base class for all authentication states
sealed class AuthState extends Equatable {
  final AuthData data;
  
  const AuthState(this.data);
  
  @override
  List<Object?> get props => [data];
}

// Initial state when the app starts
final class AuthInitial extends AuthState {
  AuthInitial() : super(const AuthData());
}

// State while checking authentication status
final class AuthLoading extends AuthState {
  AuthLoading(AuthData data) : super(data.copyWith(isLoading: true));
}

// State when user is authenticated
final class Authenticated extends AuthState {
  Authenticated(AuthData data) : super(
    data.copyWith(
      isAuthenticated: true,
      isLoading: false,
      errorMessage: null,
    ),
  );
}

// State when user is not authenticated
final class Unauthenticated extends AuthState {
  Unauthenticated(AuthData data) : super(
    data.copyWith(
      isAuthenticated: false,
      user: null,
      isLoading: false,
    ),
  );
}

// State during authentication process
final class AuthInProgress extends AuthState {
  AuthInProgress(AuthData data) : super(data.copyWith(isLoading: true));
}

// State when authentication fails
final class AuthError extends AuthState {
  AuthError(AuthData data, String message) : super(
    data.copyWith(
      errorMessage: message,
      isLoading: false,
    ),
  );
}

// State when password reset email is sent
final class PasswordResetEmailSent extends AuthState {
  PasswordResetEmailSent(AuthData data) : super(
    data.copyWith(
      isLoading: false,
      errorMessage: null,
    ),
  );
} 