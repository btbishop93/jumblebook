import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/notes/domain/repositories/notes_repository.dart';
import 'package:jumblebook/features/notes/domain/usecases/delete_note.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  late DeleteNote useCase;
  late MockNotesRepository mockRepository;

  setUp(() {
    mockRepository = MockNotesRepository();
    useCase = DeleteNote(mockRepository);
  });

  final testUserId = 'test-user-id';
  final testNoteId = 'test-note-id';

  test('should delete note from the repository', () async {
    // Arrange
    when(() => mockRepository.deleteNote(testUserId, testNoteId))
        .thenAnswer((_) async => null);

    // Act
    await useCase(userId: testUserId, noteId: testNoteId);

    // Assert
    verify(() => mockRepository.deleteNote(testUserId, testNoteId)).called(1);
  });

  test('should propagate errors from the repository', () async {
    // Arrange
    final error = Exception('Repository error');
    when(() => mockRepository.deleteNote(testUserId, testNoteId))
        .thenThrow(error);

    // Act & Assert
    expect(
      () => useCase(userId: testUserId, noteId: testNoteId),
      throwsA(isA<Exception>()),
    );
    verify(() => mockRepository.deleteNote(testUserId, testNoteId)).called(1);
  });
} 