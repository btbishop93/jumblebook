import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/authentication/domain/entities/user.dart';
import 'package:jumblebook/features/authentication/domain/repositories/auth_repository.dart';
import 'package:jumblebook/features/authentication/domain/usecases/sign_in_anonymously.dart';
import 'package:jumblebook/features/authentication/domain/usecases/auth_params.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInAnonymously useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInAnonymously(mockRepository);
  });

  final testUser = User(
    id: 'test-user-id',
    email: '',
    displayName: 'Anonymous User',
  );

  test('should sign in anonymously through the repository', () async {
    // Arrange
    when(() => mockRepository.signInAnonymously())
        .thenAnswer((_) async => testUser);

    // Act
    final result = await useCase(const NoParams());

    // Assert
    expect(result, equals(testUser));
    verify(() => mockRepository.signInAnonymously()).called(1);
  });

  test('should propagate errors from the repository', () async {
    // Arrange
    final error = Exception('Anonymous sign in failed');
    when(() => mockRepository.signInAnonymously()).thenThrow(error);

    // Act & Assert
    expect(
      () => useCase(const NoParams()),
      throwsA(isA<Exception>()),
    );
    verify(() => mockRepository.signInAnonymously()).called(1);
  });
}
