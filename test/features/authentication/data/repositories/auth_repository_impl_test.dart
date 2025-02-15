import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/authentication/data/datasources/firebase_auth_datasource.dart';
import 'package:jumblebook/features/authentication/data/models/user_model.dart';
import 'package:jumblebook/features/authentication/data/repositories/auth_repository_impl.dart';

class MockAuthDataSource extends Mock implements AuthDataSource {}

void main() {
  late AuthRepositoryImpl authRepository;
  late MockAuthDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAuthDataSource();
    authRepository = AuthRepositoryImpl(mockDataSource);
  });

  final testUser = UserModel(
    id: 'test-uid',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  group('signInWithEmailAndPassword', () {
    test('should sign in with email and password successfully', () async {
      // Arrange
      when(() => mockDataSource.signInWithEmailAndPassword(
        any(),
        any(),
      )).thenAnswer((_) async => testUser);

      // Act
      final result = await authRepository.signInWithEmailAndPassword(
        'test@example.com',
        'password123',
      );

      // Assert
      expect(result, equals(testUser));
      verify(() => mockDataSource.signInWithEmailAndPassword(
        'test@example.com',
        'password123',
      )).called(1);
    });

    test('should throw exception when sign in fails', () async {
      // Arrange
      when(() => mockDataSource.signInWithEmailAndPassword(
        any(),
        any(),
      )).thenThrow(Exception('Invalid credentials'));

      // Act & Assert
      expect(
        () => authRepository.signInWithEmailAndPassword(
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
      when(() => mockDataSource.signUpWithEmailAndPassword(
        any(),
        any(),
      )).thenAnswer((_) async => testUser);

      // Act
      final result = await authRepository.signUpWithEmailAndPassword(
        'new@example.com',
        'password123',
      );

      // Assert
      expect(result, equals(testUser));
      verify(() => mockDataSource.signUpWithEmailAndPassword(
        'new@example.com',
        'password123',
      )).called(1);
    });

    test('should throw exception when email is already in use', () async {
      // Arrange
      when(() => mockDataSource.signUpWithEmailAndPassword(
        any(),
        any(),
      )).thenThrow(Exception('Email already in use'));

      // Act & Assert
      expect(
        () => authRepository.signUpWithEmailAndPassword(
          'existing@example.com',
          'password123',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('signInWithGoogle', () {
    test('should sign in with Google successfully', () async {
      // Arrange
      when(() => mockDataSource.signInWithGoogle())
          .thenAnswer((_) async => testUser);

      // Act
      final result = await authRepository.signInWithGoogle();

      // Assert
      expect(result, equals(testUser));
      verify(() => mockDataSource.signInWithGoogle()).called(1);
    });

    test('should throw exception when Google sign in fails', () async {
      // Arrange
      when(() => mockDataSource.signInWithGoogle())
          .thenThrow(Exception('Google sign in failed'));

      // Act & Assert
      expect(
        () => authRepository.signInWithGoogle(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('signInAnonymously', () {
    test('should sign in anonymously successfully', () async {
      // Arrange
      when(() => mockDataSource.signInAnonymously())
          .thenAnswer((_) async => testUser);

      // Act
      final result = await authRepository.signInAnonymously();

      // Assert
      expect(result, equals(testUser));
      verify(() => mockDataSource.signInAnonymously()).called(1);
    });

    test('should throw exception when anonymous sign in fails', () async {
      // Arrange
      when(() => mockDataSource.signInAnonymously())
          .thenThrow(Exception('Failed to sign in anonymously'));

      // Act & Assert
      expect(
        () => authRepository.signInAnonymously(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('signOut', () {
    test('should sign out successfully', () async {
      // Arrange
      when(() => mockDataSource.signOut()).thenAnswer((_) async => null);

      // Act & Assert
      await expectLater(authRepository.signOut(), completes);
      verify(() => mockDataSource.signOut()).called(1);
    });

    test('should throw exception when sign out fails', () async {
      // Arrange
      when(() => mockDataSource.signOut())
          .thenThrow(Exception('Failed to sign out'));

      // Act & Assert
      expect(
        () => authRepository.signOut(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('resetPassword', () {
    test('should send password reset email successfully', () async {
      // Arrange
      when(() => mockDataSource.resetPassword(any()))
          .thenAnswer((_) async => null);

      // Act & Assert
      await expectLater(
        authRepository.resetPassword('test@example.com'),
        completes,
      );
      verify(() => mockDataSource.resetPassword('test@example.com')).called(1);
    });

    test('should throw exception when reset password fails', () async {
      // Arrange
      when(() => mockDataSource.resetPassword(any()))
          .thenThrow(Exception('User not found'));

      // Act & Assert
      expect(
        () => authRepository.resetPassword('nonexistent@example.com'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('authStateChanges', () {
    test('should emit user when auth state changes', () async {
      // Arrange
      final authStates = Stream.fromIterable([testUser]);
      when(() => mockDataSource.authStateChanges)
          .thenAnswer((_) => authStates);

      // Act & Assert
      expect(
        authRepository.authStateChanges,
        emits(equals(testUser)),
      );
    });

    test('should emit null when user signs out', () async {
      // Arrange
      final authStates = Stream.fromIterable([null]);
      when(() => mockDataSource.authStateChanges)
          .thenAnswer((_) => authStates);

      // Act & Assert
      expect(
        authRepository.authStateChanges,
        emits(null),
      );
    });
  });

  group('currentUser', () {
    test('should return current user when signed in', () {
      // Arrange
      when(() => mockDataSource.currentUser).thenReturn(testUser);

      // Act & Assert
      expect(authRepository.currentUser, equals(testUser));
    });

    test('should return null when not signed in', () {
      // Arrange
      when(() => mockDataSource.currentUser).thenReturn(null);

      // Act & Assert
      expect(authRepository.currentUser, isNull);
    });
  });
} 