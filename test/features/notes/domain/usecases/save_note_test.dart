import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/notes/domain/entities/note.dart';
import 'package:jumblebook/features/notes/domain/repositories/notes_repository.dart';
import 'package:jumblebook/features/notes/domain/usecases/save_note.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  late SaveNote useCase;
  late MockNotesRepository mockRepository;

  setUp(() {
    mockRepository = MockNotesRepository();
    useCase = SaveNote(mockRepository);
  });

  final testUserId = 'test-user-id';
  final testNote = Note(
    id: 'test-note-id',
    title: 'Test Note',
    content: 'Test content',
    date: DateTime(2024),
  );

  test('should save note to the repository', () async {
    // Arrange
    when(() => mockRepository.saveNote(testUserId, testNote))
        .thenAnswer((_) async => null);

    // Act
    await useCase(userId: testUserId, note: testNote);

    // Assert
    verify(() => mockRepository.saveNote(testUserId, testNote)).called(1);
  });

  test('should propagate errors from the repository', () async {
    // Arrange
    final error = Exception('Repository error');
    when(() => mockRepository.saveNote(testUserId, testNote)).thenThrow(error);

    // Act & Assert
    expect(
      () => useCase(userId: testUserId, note: testNote),
      throwsA(isA<Exception>()),
    );
    verify(() => mockRepository.saveNote(testUserId, testNote)).called(1);
  });
}
