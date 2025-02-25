import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/authentication/domain/entities/user.dart';
import 'package:jumblebook/features/authentication/domain/repositories/auth_repository.dart';
import 'package:jumblebook/features/authentication/domain/usecases/sign_up_with_email.dart';
import 'package:jumblebook/features/authentication/domain/usecases/auth_params.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignUpWithEmail useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignUpWithEmail(mockRepository);
  });

  final testEmail = 'test@example.com';
  final testPassword = 'password123';
  final testUser = User(
    id: 'test-user-id',
    email: testEmail,
    displayName: 'Test User',
  );

  test('should sign up with email and password through the repository',
      () async {
    // Arrange
    when(() =>
            mockRepository.signUpWithEmailAndPassword(testEmail, testPassword))
        .thenAnswer((_) async => testUser);

    // Act
    final result = await useCase(EmailAuthParams(
      email: testEmail,
      password: testPassword,
    ));

    // Assert
    expect(result, equals(testUser));
    verify(() =>
            mockRepository.signUpWithEmailAndPassword(testEmail, testPassword))
        .called(1);
  });

  test('should propagate errors from the repository', () async {
    // Arrange
    final error = Exception('Email already in use');
    when(() =>
            mockRepository.signUpWithEmailAndPassword(testEmail, testPassword))
        .thenThrow(error);

    // Act & Assert
    expect(
      () => useCase(EmailAuthParams(
        email: testEmail,
        password: testPassword,
      )),
      throwsA(isA<Exception>()),
    );
    verify(() =>
            mockRepository.signUpWithEmailAndPassword(testEmail, testPassword))
        .called(1);
  });

  test('should validate empty email', () async {
    // Act & Assert
    expect(
      () => useCase(EmailAuthParams(
        email: '',
        password: testPassword,
      )),
      throwsA(isA<ArgumentError>()),
    );

    verifyNever(() => mockRepository.signUpWithEmailAndPassword(any(), any()));
  });

  test('should validate empty password', () async {
    // Act & Assert
    expect(
      () => useCase(EmailAuthParams(
        email: testEmail,
        password: '',
      )),
      throwsA(isA<ArgumentError>()),
    );

    verifyNever(() => mockRepository.signUpWithEmailAndPassword(any(), any()));
  });

  test('should validate password length', () async {
    // Act & Assert
    expect(
      () => useCase(EmailAuthParams(
        email: testEmail,
        password: '12345', // Less than 6 characters
      )),
      throwsA(isA<ArgumentError>()),
    );

    verifyNever(() => mockRepository.signUpWithEmailAndPassword(any(), any()));
  });
}
