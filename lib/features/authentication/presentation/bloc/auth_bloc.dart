import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_params.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/sign_in_with_apple.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import 'auth_data.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithApple _signInWithApple;
  final SignInAnonymously _signInAnonymously;
  final SignOut _signOut;
  final ResetPassword _resetPassword;
  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SignInWithApple signInWithApple,
    required SignInAnonymously signInAnonymously,
    required SignOut signOut,
    required ResetPassword resetPassword,
  })  : _authRepository = authRepository,
        _signInWithEmail = signInWithEmail,
        _signUpWithEmail = signUpWithEmail,
        _signInWithGoogle = signInWithGoogle,
        _signInWithApple = signInWithApple,
        _signInAnonymously = signInAnonymously,
        _signOut = signOut,
        _resetPassword = resetPassword,
        super(AuthInitial()) {
    // Register event handlers
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInWithEmailRequested>(_onSignInWithEmailRequested);
    on<SignUpWithEmailRequested>(_onSignUpWithEmailRequested);
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<SignInWithAppleRequested>(_onSignInWithAppleRequested);
    on<SignInAnonymouslyRequested>(_onSignInAnonymouslyRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);

    // Subscribe to auth state changes when bloc is created
    _subscribeToAuthChanges();
  }

  void _subscribeToAuthChanges() {
    _authStateSubscription?.cancel();
    _authStateSubscription = _authRepository.authStateChanges.listen(
      (user) {
        if (user != null) {
          add(CheckAuthStatus()); // Trigger a state check when auth state changes
        }
      },
    );
  }

  // Handle checking authentication status
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(state.data));

    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      emit(Authenticated(state.data.copyWith(
        user: currentUser,
        email: currentUser.email,
      )));
    } else {
      // Keep the last email for convenience
      final lastEmail = state.data.email;
      emit(Unauthenticated(AuthData(email: lastEmail)));
    }
  }

  // Handle sign in with email request
  Future<void> _onSignInWithEmailRequested(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(state.data.copyWith(email: event.email)));

    try {
      final user = await _signInWithEmail(
        EmailAuthParams(
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

  // Handle sign up with email request
  Future<void> _onSignUpWithEmailRequested(
    SignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(state.data.copyWith(email: event.email)));

    try {
      final user = await _signUpWithEmail(
        EmailAuthParams(
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

  // Handle sign in with google request
  Future<void> _onSignInWithGoogleRequested(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(state.data));

    try {
      final user = await _signInWithGoogle(const NoParams());
      emit(Authenticated(state.data.copyWith(
        user: user,
        email: user.email,
      )));
    } catch (e) {
      emit(AuthError(state.data, e.toString()));
    }
  }

  // Handle sign in with apple request
  Future<void> _onSignInWithAppleRequested(
    SignInWithAppleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(state.data));

    try {
      final user = await _signInWithApple(const NoParams());
      emit(Authenticated(state.data.copyWith(
        user: user,
        email: user.email,
      )));
    } catch (e) {
      emit(AuthError(state.data, e.toString()));
    }
  }

  // Handle sign in anonymously request
  Future<void> _onSignInAnonymouslyRequested(
    SignInAnonymouslyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(state.data));

    try {
      final user = await _signInAnonymously(const NoParams());
      emit(Authenticated(state.data.copyWith(user: user)));
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

    try {
      await _signOut(const NoParams());
      // Preserve the email for convenience on next login
      final lastEmail = state.data.email;
      emit(Unauthenticated(AuthData(email: lastEmail)));
    } catch (e) {
      emit(AuthError(state.data, e.toString()));
    }
  }

  // Handle password reset request
  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(state.data.copyWith(email: event.email)));

    try {
      await _resetPassword(EmailOnlyParams(email: event.email));
      emit(PasswordResetEmailSent(state.data.copyWith(email: event.email)));
    } catch (e) {
      emit(AuthError(state.data, e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _authStateSubscription?.cancel();
    return super.close();
  }
}
