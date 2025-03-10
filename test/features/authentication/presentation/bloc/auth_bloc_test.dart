import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/authentication/domain/entities/user.dart';
import 'package:jumblebook/features/authentication/domain/usecases/auth_params.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_event.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_state.dart';
import 'mocks/mock_auth_repository.dart';
import 'mocks/mock_use_cases.dart';

/// This test file verifies the behavior of the AuthBloc, which manages authentication state
/// and handles various authentication operations like sign in, sign up, and password reset.
///
/// The tests are organized into groups based on different authentication events:
/// - Initial state verification
/// - Auth state changes monitoring
/// - Authentication status checking
/// - Email/password authentication (sign in and sign up)
/// - Social authentication (Google and Apple)
/// - Anonymous authentication
/// - Sign out
/// - Password reset

// Register fallback values for Mocktail to handle auth parameter objects
class FakeEmailAuthParams extends Fake implements EmailAuthParams {}

class FakeEmailOnlyParams extends Fake implements EmailOnlyParams {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Declare test-wide variables
  late AuthBloc authBloc;
  late MockAuthRepository authRepository;
  late MockSignInWithEmail signInWithEmail;
  late MockSignUpWithEmail signUpWithEmail;
  late MockSignInWithGoogle signInWithGoogle;
  late MockSignInWithApple signInWithApple;
  late MockSignInAnonymously signInAnonymously;
  late MockSignOut signOut;
  late MockResetPassword resetPassword;
  late MockDeleteUserData deleteUserData;

  // Test user fixture for reuse across tests
  final testUser = User(
    id: 'test-id',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  setUpAll(() {
    // Register fallback values for Mocktail to handle parameter matching
    registerFallbackValue(FakeEmailAuthParams());
    registerFallbackValue(FakeEmailOnlyParams());
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    // Reset mock state and initialize fresh mocks before each test
    resetMocktailState();

    // Initialize all required mocks
    authRepository = MockAuthRepository();
    signInWithEmail = MockSignInWithEmail();
    signUpWithEmail = MockSignUpWithEmail();
    signInWithGoogle = MockSignInWithGoogle();
    signInWithApple = MockSignInWithApple();
    signInAnonymously = MockSignInAnonymously();
    signOut = MockSignOut();
    resetPassword = MockResetPassword();
    deleteUserData = MockDeleteUserData();

    // Set up default stub behavior
    when(() => authRepository.authStateChanges)
        .thenAnswer((_) => Stream.empty());
    when(() => authRepository.currentUser).thenReturn(null);

    // Create a fresh AuthBloc instance for each test
    authBloc = AuthBloc(
      authRepository: authRepository,
      signInWithEmail: signInWithEmail,
      signUpWithEmail: signUpWithEmail,
      signInWithGoogle: signInWithGoogle,
      signInWithApple: signInWithApple,
      signInAnonymously: signInAnonymously,
      signOut: signOut,
      resetPassword: resetPassword,
      deleteUserData: deleteUserData,
    );
  });

  tearDown(() {
    // Clean up resources after each test
    authBloc.close();
    resetMocktailState();
  });

  // Verify initial state when AuthBloc is created
  test('initial state is AuthInitial', () {
    expect(authBloc.state, isA<AuthInitial>());
  });

  // Test authentication state change subscription
  group('Auth State Changes', () {
    late StreamController<User?> controller;

    setUp(() {
      controller = StreamController<User?>.broadcast();
    });

    tearDown(() {
      controller.close();
    });

    blocTest<AuthBloc, AuthState>(
      'subscribes to auth state changes and emits new states',
      build: () {
        when(() => authRepository.authStateChanges)
            .thenAnswer((_) => controller.stream);
        when(() => authRepository.currentUser).thenReturn(testUser);

        // Simulate delayed auth state change
        Future.delayed(const Duration(milliseconds: 50), () {
          controller.add(testUser);
        });

        return authBloc;
      },
      act: (bloc) async {
        bloc.add(CheckAuthStatus());
        await Future.delayed(const Duration(milliseconds: 100));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>(),
      ],
    );
  });

  // Test authentication status check functionality
  group('CheckAuthStatus', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when user is logged in',
      build: () {
        when(() => authRepository.currentUser).thenReturn(testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatus()),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when user is not logged in',
      build: () {
        when(() => authRepository.currentUser).thenReturn(null);
        return authBloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatus()),
      expect: () => [
        isA<AuthLoading>(),
        isA<Unauthenticated>(),
      ],
    );
  });

  // Test email/password sign in functionality
  group('SignInWithEmailRequested', () {
    const email = 'test@example.com';
    const password = 'password123';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when sign in is successful',
      build: () {
        when(() => signInWithEmail(any())).thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInWithEmailRequested(
        email: email,
        password: password,
      )),
      wait: const Duration(milliseconds: 100),
      verify: (_) {
        verify(() => signInWithEmail(any())).called(1);
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when sign in fails',
      build: () {
        when(() => signInWithEmail(any()))
            .thenThrow(Exception('Invalid credentials'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInWithEmailRequested(
        email: email,
        password: 'wrong-password',
      )),
      verify: (_) {
        verify(() => signInWithEmail(any())).called(1);
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  // Test email/password sign up functionality
  group('SignUpWithEmailRequested', () {
    const email = 'new@example.com';
    const password = 'password123';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when sign up is successful',
      build: () {
        when(() => signUpWithEmail(any())).thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignUpWithEmailRequested(
        email: email,
        password: password,
      )),
      wait: const Duration(milliseconds: 100),
      verify: (_) {
        verify(() => signUpWithEmail(any())).called(1);
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when sign up fails',
      build: () {
        when(() => signUpWithEmail(any()))
            .thenThrow(Exception('Email already in use'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignUpWithEmailRequested(
        email: 'existing@example.com',
        password: 'password',
      )),
      wait: const Duration(milliseconds: 100),
      verify: (_) {
        verify(() => signUpWithEmail(any())).called(1);
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  // Test Google sign in functionality
  group('SignInWithGoogleRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when Google sign in is successful',
      build: () {
        when(() => signInWithGoogle(any())).thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(SignInWithGoogleRequested()),
      verify: (_) {
        verify(() => signInWithGoogle(any())).called(1);
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when Google sign in is cancelled',
      build: () {
        when(() => signInWithGoogle(any()))
            .thenThrow(Exception('Google sign in cancelled'));
        return authBloc;
      },
      act: (bloc) => bloc.add(SignInWithGoogleRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  // Test Apple sign in functionality
  group('SignInWithAppleRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when Apple sign in is successful',
      build: () {
        when(() => signInWithApple(any())).thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(SignInWithAppleRequested()),
      verify: (_) {
        verify(() => signInWithApple(any())).called(1);
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when Apple sign in fails',
      build: () {
        when(() => signInWithApple(any()))
            .thenThrow(Exception('Apple sign in failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(SignInWithAppleRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  // Test anonymous sign in functionality
  group('SignInAnonymouslyRequested', () {
    final anonymousUser = User(
      id: 'anon-id',
      email: '',
      displayName: null,
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when anonymous sign in is successful',
      build: () {
        when(() => signInAnonymously(any()))
            .thenAnswer((_) async => anonymousUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(SignInAnonymouslyRequested()),
      verify: (_) {
        verify(() => signInAnonymously(any())).called(1);
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when anonymous sign in fails',
      build: () {
        when(() => signInAnonymously(any()))
            .thenThrow(Exception('Anonymous sign in failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(SignInAnonymouslyRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  // Test sign out functionality
  group('SignOutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when sign out is successful',
      build: () {
        when(() => signOut(any())).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(SignOutRequested()),
      verify: (_) {
        verify(() => signOut(any())).called(1);
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<Unauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when sign out fails',
      build: () {
        when(() => signOut(any())).thenThrow(Exception('Sign out failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(SignOutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  // Test password reset functionality
  group('ResetPasswordRequested', () {
    const email = 'test@example.com';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, PasswordResetEmailSent] when password reset is successful',
      build: () {
        when(() => resetPassword.call(any())).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const ResetPasswordRequested(email: email)),
      wait: const Duration(milliseconds: 100),
      verify: (_) {
        verify(() => resetPassword.call(any())).called(1);
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<PasswordResetEmailSent>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when password reset fails',
      build: () {
        when(() => resetPassword.call(any()))
            .thenThrow(Exception('Invalid email'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const ResetPasswordRequested(
        email: 'invalid@example.com',
      )),
      wait: const Duration(milliseconds: 100),
      verify: (_) {
        verify(() => resetPassword.call(any())).called(1);
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });
}
