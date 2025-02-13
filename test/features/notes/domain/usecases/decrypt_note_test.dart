import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/notes/domain/entities/note.dart';
import 'package:jumblebook/features/notes/domain/repositories/notes_repository.dart';
import 'package:jumblebook/features/notes/domain/usecases/decrypt_note.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  late DecryptNote useCase;
  late MockNotesRepository mockRepository;

  setUp(() {
    mockRepository = MockNotesRepository();
    useCase = DecryptNote(mockRepository);
  });

  final testUserId = 'test-user-id';
  final testPassword = 'test-password';
  final encryptedNote = Note(
    id: 'test-note-id',
    title: 'Test Note',
    content: 'Encrypted content',
    date: DateTime(2024),
    isEncrypted: true,
    password: testPassword,
  );

  final decryptedNote = Note(
    id: 'test-note-id',
    title: 'Test Note',
    content: 'Decrypted content',
    date: DateTime(2024),
    isEncrypted: false,
    password: '',
  );

  test('should decrypt note using the repository', () async {
    // Arrange
    when(() => mockRepository.decryptNote(testUserId, encryptedNote, testPassword))
        .thenAnswer((_) async => decryptedNote);

    // Act
    final result = await useCase(
      userId: testUserId,
      note: encryptedNote,
      password: testPassword,
    );

    // Assert
    expect(result, equals(decryptedNote));
    verify(() => mockRepository.decryptNote(testUserId, encryptedNote, testPassword))
        .called(1);
  });

  test('should propagate errors from the repository', () async {
    // Arrange
    final error = Exception('Repository error');
    when(() => mockRepository.decryptNote(testUserId, encryptedNote, testPassword))
        .thenThrow(error);

    // Act & Assert
    expect(
      () => useCase(
        userId: testUserId,
        note: encryptedNote,
        password: testPassword,
      ),
      throwsA(isA<Exception>()),
    );
    verify(() => mockRepository.decryptNote(testUserId, encryptedNote, testPassword))
        .called(1);
  });

  test('should throw ArgumentError when wrong password is provided', () async {
    // Arrange
    when(() => mockRepository.decryptNote(testUserId, encryptedNote, 'wrong-password'))
        .thenThrow(ArgumentError('Invalid password'));

    // Act & Assert
    expect(
      () => useCase(
        userId: testUserId,
        note: encryptedNote,
        password: 'wrong-password',
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
} 