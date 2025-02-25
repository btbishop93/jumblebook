import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/authentication/domain/entities/user.dart';
import 'package:jumblebook/features/authentication/domain/repositories/auth_repository.dart';
import 'package:jumblebook/features/authentication/domain/usecases/sign_in_with_apple.dart';
import 'package:jumblebook/features/authentication/domain/usecases/auth_params.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInWithApple useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithApple(mockRepository);
  });

  final testUser = User(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  test('should sign in with Apple through the repository', () async {
    // Arrange
    when(() => mockRepository.signInWithApple())
        .thenAnswer((_) async => testUser);

    // Act
    final result = await useCase(const NoParams());

    // Assert
    expect(result, equals(testUser));
    verify(() => mockRepository.signInWithApple()).called(1);
  });

  test('should propagate errors from the repository', () async {
    // Arrange
    final error = Exception('Apple sign in failed');
    when(() => mockRepository.signInWithApple()).thenThrow(error);

    // Act & Assert
    expect(
      () => useCase(const NoParams()),
      throwsA(isA<Exception>()),
    );
    verify(() => mockRepository.signInWithApple()).called(1);
  });
}
