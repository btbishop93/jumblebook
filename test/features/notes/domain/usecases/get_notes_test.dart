import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/notes/domain/entities/note.dart';
import 'package:jumblebook/features/notes/domain/repositories/notes_repository.dart';
import 'package:jumblebook/features/notes/domain/usecases/get_notes.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  late GetNotes useCase;
  late MockNotesRepository mockRepository;

  setUp(() {
    mockRepository = MockNotesRepository();
    useCase = GetNotes(mockRepository);
  });

  final testUserId = 'test-user-id';
  final testNote = Note(
    id: 'test-note-id',
    title: 'Test Note',
    content: 'Test content',
    date: DateTime(2024),
  );

  test('should get notes from the repository', () async {
    // Arrange
    final notes = [testNote];
    when(() => mockRepository.getNotes(testUserId))
        .thenAnswer((_) => Stream.value(notes));

    // Act
    final result = useCase(testUserId);

    // Assert
    await expectLater(result, emits(notes));
    verify(() => mockRepository.getNotes(testUserId)).called(1);
  });

  test('should propagate errors from the repository', () async {
    // Arrange
    final error = Exception('Repository error');
    when(() => mockRepository.getNotes(testUserId))
        .thenAnswer((_) => Stream.error(error));

    // Act
    final result = useCase(testUserId);

    // Assert
    await expectLater(result, emitsError(isA<Exception>()));
    verify(() => mockRepository.getNotes(testUserId)).called(1);
  });
} 