import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import 'auth_data.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail _signInWithEmail;
  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({
    required SignInWithEmail signInWithEmail,
  })  : _signInWithEmail = signInWithEmail,
        super(AuthInitial()) {
    // Register event handlers
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInWithEmailRequested>(_onSignInWithEmailRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
  }

  // Handle checking authentication status
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(state.data));
    // TODO: Implement auth state check using repository
  }

  // Handle sign in with email request
  Future<void> _onSignInWithEmailRequested(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(state.data.copyWith(email: event.email)));
    
    try {
      final user = await _signInWithEmail(
        SignInWithEmailParams(
          email: event.email,
          password: event.password,
        ),
      );
      
      emit(Authenticated(state.data.copyWith(
        user: user,
        email: event.email,
      )));
    } catch (e) {
      emit(AuthError(state.data, e.toString()));
    }
  }

  // Handle sign out request
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(state.data));
    // Preserve the email for convenience on next login
    final lastEmail = state.data.email;
    emit(Unauthenticated(AuthData(email: lastEmail)));
  }

  // Handle password reset request
  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(state.data));
    // TODO: Implement password reset
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
} 