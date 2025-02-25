import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/notes/domain/repositories/notes_repository.dart';
import 'package:jumblebook/features/notes/domain/usecases/update_lock_counter.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  late UpdateLockCounter useCase;
  late MockNotesRepository mockRepository;

  setUp(() {
    mockRepository = MockNotesRepository();
    useCase = UpdateLockCounter(mockRepository);
  });

  final testUserId = 'test-user-id';
  final testNoteId = 'test-note-id';
  const testLockCounter = 3;

  test('should update lock counter in the repository', () async {
    // Arrange
    when(() => mockRepository.updateLockCounter(
        testUserId, testNoteId, testLockCounter)).thenAnswer((_) async => null);

    // Act
    await useCase(
      userId: testUserId,
      noteId: testNoteId,
      lockCounter: testLockCounter,
    );

    // Assert
    verify(() => mockRepository.updateLockCounter(
        testUserId, testNoteId, testLockCounter)).called(1);
  });

  test('should propagate errors from the repository', () async {
    // Arrange
    final error = Exception('Repository error');
    when(() => mockRepository.updateLockCounter(
        testUserId, testNoteId, testLockCounter)).thenThrow(error);

    // Act & Assert
    expect(
      () => useCase(
        userId: testUserId,
        noteId: testNoteId,
        lockCounter: testLockCounter,
      ),
      throwsA(isA<Exception>()),
    );
    verify(() => mockRepository.updateLockCounter(
        testUserId, testNoteId, testLockCounter)).called(1);
  });

  test('should throw ArgumentError when lock counter is negative', () async {
    // Act & Assert
    expect(
      () => useCase(
        userId: testUserId,
        noteId: testNoteId,
        lockCounter: -1,
      ),
      throwsA(isA<ArgumentError>()),
    );

    // Verify repository was not called
    verifyNever(() => mockRepository.updateLockCounter(any(), any(), any()));
  });
}
