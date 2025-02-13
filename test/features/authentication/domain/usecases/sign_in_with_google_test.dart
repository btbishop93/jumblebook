import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/authentication/domain/entities/user.dart';
import 'package:jumblebook/features/authentication/domain/repositories/auth_repository.dart';
import 'package:jumblebook/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:jumblebook/features/authentication/domain/usecases/auth_params.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInWithGoogle useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithGoogle(mockRepository);
  });

  final testUser = User(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  test('should sign in with Google through the repository', () async {
    // Arrange
    when(() => mockRepository.signInWithGoogle())
        .thenAnswer((_) async => testUser);

    // Act
    final result = await useCase(const NoParams());

    // Assert
    expect(result, equals(testUser));
    verify(() => mockRepository.signInWithGoogle()).called(1);
  });

  test('should propagate errors from the repository', () async {
    // Arrange
    final error = Exception('Google sign in failed');
    when(() => mockRepository.signInWithGoogle())
        .thenThrow(error);

    // Act & Assert
    expect(
      () => useCase(const NoParams()),
      throwsA(isA<Exception>()),
    );
    verify(() => mockRepository.signInWithGoogle()).called(1);
  });
} 