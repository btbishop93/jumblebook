import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/notes/domain/entities/note.dart';
import 'package:jumblebook/features/notes/domain/repositories/notes_repository.dart';
import 'package:jumblebook/features/notes/domain/usecases/jumble_note.dart';
class MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  late JumbleNote useCase;
  late MockNotesRepository mockRepository;

  setUp(() {
    mockRepository = MockNotesRepository();
    useCase = JumbleNote(mockRepository);
  });

  final testUserId = 'test-user-id';
  final testPassword = 'test-password';
  final testNote = Note(
    id: 'test-note-id',
    title: 'Test Note',
    content: 'Test content',
    date: DateTime(2024),
  );

  final jumbledNote = Note(
    id: 'test-note-id',
    title: 'Test Note',
    content: 'Jumbled content',
    date: DateTime(2024),
    isEncrypted: true,
    password: testPassword,
  );

  test('should jumble note using the repository', () async {
    // Arrange
    when(() => mockRepository.jumbleNote(testUserId, testNote, testPassword))
        .thenAnswer((_) async => jumbledNote);

    // Act
    final result = await useCase(
      userId: testUserId,
      note: testNote,
      password: testPassword,
    );

    // Assert
    expect(result, equals(jumbledNote));
    verify(() => mockRepository.jumbleNote(testUserId, testNote, testPassword))
        .called(1);
  });

  test('should propagate errors from the repository', () async {
    // Arrange
    final error = Exception('Repository error');
    when(() => mockRepository.jumbleNote(testUserId, testNote, testPassword))
        .thenThrow(error);

    // Act & Assert
    expect(
      () => useCase(
        userId: testUserId,
        note: testNote,
        password: testPassword,
      ),
      throwsA(isA<Exception>()),
    );
    verify(() => mockRepository.jumbleNote(testUserId, testNote, testPassword))
        .called(1);
  });
} 