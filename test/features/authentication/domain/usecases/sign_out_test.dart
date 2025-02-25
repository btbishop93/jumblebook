import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/authentication/domain/repositories/auth_repository.dart';
import 'package:jumblebook/features/authentication/domain/usecases/sign_out.dart';
import 'package:jumblebook/features/authentication/domain/usecases/auth_params.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignOut useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignOut(mockRepository);
  });

  test('should sign out through the repository', () async {
    // Arrange
    when(() => mockRepository.signOut()).thenAnswer((_) async {});

    // Act
    await useCase(const NoParams());

    // Assert
    verify(() => mockRepository.signOut()).called(1);
  });

  test('should propagate errors from the repository', () async {
    // Arrange
    final error = Exception('Sign out failed');
    when(() => mockRepository.signOut()).thenThrow(error);

    // Act & Assert
    expect(
      () => useCase(const NoParams()),
      throwsA(isA<Exception>()),
    );
    verify(() => mockRepository.signOut()).called(1);
  });
}
