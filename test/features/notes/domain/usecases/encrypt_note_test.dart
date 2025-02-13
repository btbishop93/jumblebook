import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/notes/domain/entities/note.dart';
import 'package:jumblebook/features/notes/domain/repositories/notes_repository.dart';
import 'package:jumblebook/features/notes/domain/usecases/encrypt_note.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  late EncryptNote useCase;
  late MockNotesRepository mockRepository;

  setUp(() {
    mockRepository = MockNotesRepository();
    useCase = EncryptNote(mockRepository);
  });

  final testUserId = 'test-user-id';
  final testPassword = 'test-password';
  final testNote = Note(
    id: 'test-note-id',
    title: 'Test Note',
    content: 'Test content',
    date: DateTime(2024),
  );

  final encryptedNote = Note(
    id: 'test-note-id',
    title: 'Test Note',
    content: 'Encrypted content',
    date: DateTime(2024),
    isEncrypted: true,
    password: testPassword,
  );

  test('should encrypt note using the repository', () async {
    // Arrange
    when(() => mockRepository.encryptNote(testUserId, testNote, testPassword))
        .thenAnswer((_) async => encryptedNote);

    // Act
    final result = await useCase(
      userId: testUserId,
      note: testNote,
      password: testPassword,
    );

    // Assert
    expect(result, equals(encryptedNote));
    verify(() => mockRepository.encryptNote(testUserId, testNote, testPassword))
        .called(1);
  });

  test('should propagate errors from the repository', () async {
    // Arrange
    final error = Exception('Repository error');
    when(() => mockRepository.encryptNote(testUserId, testNote, testPassword))
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
    verify(() => mockRepository.encryptNote(testUserId, testNote, testPassword))
        .called(1);
  });
} 