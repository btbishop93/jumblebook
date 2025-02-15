import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/authentication/data/datasources/firebase_auth_datasource.dart';
import 'package:jumblebook/features/authentication/data/models/user_model.dart';

class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockUserCredential extends Mock implements firebase_auth.UserCredential {}
class MockFirebaseUser extends Mock implements firebase_auth.User {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}

// Fake classes for fallback values
class FakeAuthCredential extends Fake implements firebase_auth.AuthCredential {}
class FakeOAuthCredential extends Fake implements firebase_auth.OAuthCredential {}

void main() {
  late FirebaseAuthDataSource dataSource;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockUserCredential mockUserCredential;
  late MockFirebaseUser mockFirebaseUser;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
    registerFallbackValue(FakeOAuthCredential());
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockUserCredential = MockUserCredential();
    mockFirebaseUser = MockFirebaseUser();

    dataSource = FirebaseAuthDataSource(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
    );

    // Default user setup
    when(() => mockFirebaseUser.uid).thenReturn('test-uid');
    when(() => mockFirebaseUser.email).thenReturn('test@example.com');
    when(() => mockFirebaseUser.displayName).thenReturn('Test User');
    when(() => mockFirebaseUser.photoURL).thenReturn(null);
    when(() => mockFirebaseUser.isAnonymous).thenReturn(false);
    when(() => mockUserCredential.user).thenReturn(mockFirebaseUser);
  });

  group('signInWithEmailAndPassword', () {
    test('should sign in with email and password successfully', () async {
      // Arrange
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await dataSource.signInWithEmailAndPassword(
        'test@example.com',
        'password123',
      );

      // Assert
      expect(result, isA<UserModel>());
      expect(result.id, equals('test-uid'));
      expect(result.email, equals('test@example.com'));
      expect(result.displayName, equals('Test User'));
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('should throw exception when sign in fails', () async {
      // Arrange
      final error = firebase_auth.FirebaseAuthException(
        code: 'wrong-password',
        message: 'Wrong password provided.',
      );
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(error);

      // Act & Assert
      expect(
        () => dataSource.signInWithEmailAndPassword(
          'test@example.com',
          'wrong-password',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('signUpWithEmailAndPassword', () {
    test('should create new account successfully', () async {
      // Arrange
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await dataSource.signUpWithEmailAndPassword(
        'new@example.com',
        'password123',
      );

      // Assert
      expect(result, isA<UserModel>());
      expect(result.id, equals('test-uid'));
      expect(result.email, equals('test@example.com'));
      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'new@example.com',
        password: 'password123',
      )).called(1);
    });

    test('should throw exception when email is already in use', () async {
      // Arrange
      final error = firebase_auth.FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'Email is already in use.',
      );
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(error);

      // Act & Assert
      expect(
        () => dataSource.signUpWithEmailAndPassword(
          'existing@example.com',
          'password123',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('signInWithGoogle', () {
    late MockGoogleSignInAccount mockGoogleAccount;
    late MockGoogleSignInAuthentication mockGoogleAuth;

    setUp(() {
      mockGoogleAccount = MockGoogleSignInAccount();
      mockGoogleAuth = MockGoogleSignInAuthentication();

      when(() => mockGoogleAccount.authentication)
          .thenAnswer((_) async => mockGoogleAuth);
      when(() => mockGoogleAuth.accessToken).thenReturn('mock-access-token');
      when(() => mockGoogleAuth.idToken).thenReturn('mock-id-token');
    });

    test('should sign in with Google successfully', () async {
      // Arrange
      when(() => mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleAccount);
      when(() => mockFirebaseAuth.signInWithCredential(any()))
          .thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await dataSource.signInWithGoogle();

      // Assert
      expect(result, isA<UserModel>());
      expect(result.id, equals('test-uid'));
      verify(() => mockGoogleSignIn.signIn()).called(1);
      verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
    });

    test('should throw exception when Google sign in is cancelled', () async {
      // Arrange
      when(() => mockGoogleSignIn.signIn())
          .thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => dataSource.signInWithGoogle(),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception when Google sign in fails', () async {
      // Arrange
      when(() => mockGoogleSignIn.signIn())
          .thenThrow(Exception('Google sign in failed'));

      // Act & Assert
      expect(
        () => dataSource.signInWithGoogle(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('signInAnonymously', () {
    test('should sign in anonymously successfully', () async {
      // Arrange
      when(() => mockFirebaseAuth.signInAnonymously())
          .thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await dataSource.signInAnonymously();

      // Assert
      expect(result, isA<UserModel>());
      expect(result.id, equals('test-uid'));
      verify(() => mockFirebaseAuth.signInAnonymously()).called(1);
    });

    test('should throw exception when anonymous sign in fails', () async {
      // Arrange
      final error = firebase_auth.FirebaseAuthException(
        code: 'operation-not-allowed',
        message: 'Anonymous auth is not enabled',
      );
      when(() => mockFirebaseAuth.signInAnonymously())
          .thenThrow(error);

      // Act & Assert
      expect(
        () => dataSource.signInAnonymously(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('signOut', () {
    test('should sign out successfully', () async {
      // Arrange
      when(() => mockFirebaseAuth.signOut())
          .thenAnswer((_) async {});
      when(() => mockGoogleSignIn.signOut())
          .thenAnswer((_) async => null);

      // Act & Assert
      await expectLater(dataSource.signOut(), completes);
      verify(() => mockFirebaseAuth.signOut()).called(1);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });

    test('should throw exception when sign out fails', () async {
      // Arrange
      when(() => mockFirebaseAuth.signOut())
          .thenThrow(Exception('Sign out failed'));

      // Act & Assert
      expect(
        () => dataSource.signOut(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('resetPassword', () {
    test('should send password reset email successfully', () async {
      // Arrange
      when(() => mockFirebaseAuth.sendPasswordResetEmail(
        email: any(named: 'email'),
      )).thenAnswer((_) async {});

      // Act & Assert
      await expectLater(
        dataSource.resetPassword('test@example.com'),
        completes,
      );
      verify(() => mockFirebaseAuth.sendPasswordResetEmail(
        email: 'test@example.com',
      )).called(1);
    });

    test('should throw exception when reset password fails', () async {
      // Arrange
      final error = firebase_auth.FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found with this email.',
      );
      when(() => mockFirebaseAuth.sendPasswordResetEmail(
        email: any(named: 'email'),
      )).thenThrow(error);

      // Act & Assert
      expect(
        () => dataSource.resetPassword('nonexistent@example.com'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('authStateChanges', () {
    test('should emit user when auth state changes', () async {
      // Arrange
      final authStates = Stream.fromIterable([mockFirebaseUser]);
      when(() => mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => authStates);

      // Act & Assert
      expect(
        dataSource.authStateChanges,
        emits(isA<UserModel>()),
      );
    });

    test('should emit null when user signs out', () async {
      // Arrange
      final authStates = Stream.fromIterable([null]);
      when(() => mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => authStates);

      // Act & Assert
      expect(
        dataSource.authStateChanges,
        emits(null),
      );
    });
  });

  group('currentUser', () {
    test('should return current user when signed in', () {
      // Arrange
      when(() => mockFirebaseAuth.currentUser)
          .thenReturn(mockFirebaseUser);

      // Act
      final result = dataSource.currentUser;

      // Assert
      expect(result, isA<UserModel>());
      expect(result?.id, equals('test-uid'));
      verify(() => mockFirebaseAuth.currentUser).called(1);
    });

    test('should return null when not signed in', () {
      // Arrange
      when(() => mockFirebaseAuth.currentUser)
          .thenReturn(null);

      // Act
      final result = dataSource.currentUser;

      // Assert
      expect(result, isNull);
      verify(() => mockFirebaseAuth.currentUser).called(1);
    });
  });
} 