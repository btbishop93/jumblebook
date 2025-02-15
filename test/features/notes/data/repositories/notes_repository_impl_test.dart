import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/notes/data/datasources/notes_remote_datasource.dart';
import 'package:jumblebook/features/notes/data/models/note_model.dart';
import 'package:jumblebook/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:jumblebook/features/notes/domain/entities/note.dart';

class MockNotesRemoteDataSource extends Mock implements NotesRemoteDataSource {}
class FakeNoteModel extends Fake implements NoteModel {}

void main() {
  late NotesRepositoryImpl repository;
  late MockNotesRemoteDataSource mockRemoteDataSource;

  final testUserId = 'test-user-id';
  final testNoteId = 'test-note-id';
  final testDate = DateTime(2024);
  final testTimestamp = Timestamp.fromDate(testDate);

  final testNoteModel = NoteModel(
    id: testNoteId,
    title: 'Test Note',
    content: 'Test content',
    date: testDate,
  );

  final testNote = Note(
    id: testNoteId,
    title: 'Test Note',
    content: 'Test content',
    date: testDate,
  );

  final encryptedNoteModel = testNoteModel.copyWith(
    isEncrypted: true,
    password: 'password123',
  ) as NoteModel;

  final encryptedNote = testNote.copyWith(
    isEncrypted: true,
    password: 'password123',
  );

  setUpAll(() {
    registerFallbackValue(FakeNoteModel());
  });

  setUp(() {
    mockRemoteDataSource = MockNotesRemoteDataSource();
    repository = NotesRepositoryImpl(mockRemoteDataSource);
  });

  group('getNotes', () {
    test('should return stream of notes from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.getNotes(testUserId))
          .thenAnswer((_) => Stream.value([testNoteModel]));

      // Act
      final result = repository.getNotes(testUserId);

      // Assert
      await expectLater(result, emits([testNoteModel]));
      verify(() => mockRemoteDataSource.getNotes(testUserId)).called(1);
    });

    test('should propagate errors from remote data source', () async {
      // Arrange
      final error = Exception('Remote error');
      when(() => mockRemoteDataSource.getNotes(testUserId))
          .thenAnswer((_) => Stream.error(error));

      // Act
      final result = repository.getNotes(testUserId);

      // Assert
      await expectLater(result, emitsError(isA<Exception>()));
    });
  });

  group('getNote', () {
    test('should return note from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.getNote(testUserId, testNoteId))
          .thenAnswer((_) async => testNoteModel);

      // Act
      final result = await repository.getNote(testUserId, testNoteId);

      // Assert
      expect(result, equals(testNoteModel));
      verify(() => mockRemoteDataSource.getNote(testUserId, testNoteId)).called(1);
    });

    test('should propagate errors from remote data source', () async {
      // Arrange
      final error = Exception('Remote error');
      when(() => mockRemoteDataSource.getNote(testUserId, testNoteId))
          .thenThrow(error);

      // Act & Assert
      expect(
        () => repository.getNote(testUserId, testNoteId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('saveNote', () {
    test('should save note to remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.saveNote(testUserId, any()))
          .thenAnswer((_) async => null);

      // Act
      await repository.saveNote(testUserId, testNote);

      // Assert
      verify(() => mockRemoteDataSource.saveNote(testUserId, any(that: isA<NoteModel>())))
          .called(1);
    });

    test('should propagate errors from remote data source', () async {
      // Arrange
      final error = Exception('Remote error');
      when(() => mockRemoteDataSource.saveNote(testUserId, any()))
          .thenThrow(error);

      // Act & Assert
      expect(
        () => repository.saveNote(testUserId, testNote),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteNote', () {
    test('should delete note from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.deleteNote(testUserId, testNoteId))
          .thenAnswer((_) async => null);

      // Act
      await repository.deleteNote(testUserId, testNoteId);

      // Assert
      verify(() => mockRemoteDataSource.deleteNote(testUserId, testNoteId))
          .called(1);
    });

    test('should propagate errors from remote data source', () async {
      // Arrange
      final error = Exception('Remote error');
      when(() => mockRemoteDataSource.deleteNote(testUserId, testNoteId))
          .thenThrow(error);

      // Act & Assert
      expect(
        () => repository.deleteNote(testUserId, testNoteId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getNoteCount', () {
    test('should return note count from remote data source', () async {
      // Arrange
      const expectedCount = 5;
      when(() => mockRemoteDataSource.getNoteCount(testUserId))
          .thenAnswer((_) async => expectedCount);

      // Act
      final result = await repository.getNoteCount(testUserId);

      // Assert
      expect(result, equals(expectedCount));
      verify(() => mockRemoteDataSource.getNoteCount(testUserId)).called(1);
    });

    test('should propagate errors from remote data source', () async {
      // Arrange
      final error = Exception('Remote error');
      when(() => mockRemoteDataSource.getNoteCount(testUserId))
          .thenThrow(error);

      // Act & Assert
      expect(
        () => repository.getNoteCount(testUserId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('jumbleNote', () {
    test('should jumble note and save to remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.saveNote(testUserId, any()))
          .thenAnswer((_) async => null);

      // Act
      await repository.jumbleNote(testUserId, testNote, 'password123');

      // Assert
      verify(() => mockRemoteDataSource.saveNote(
        testUserId,
        any(that: isA<NoteModel>()),
      )).called(1);
    });

    test('should propagate errors from remote data source', () async {
      // Arrange
      final error = Exception('Remote error');
      when(() => mockRemoteDataSource.saveNote(testUserId, any()))
          .thenThrow(error);

      // Act & Assert
      expect(
        () => repository.jumbleNote(testUserId, testNote, 'password123'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('unjumbleNote', () {
    test('should unjumble note and save to remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.saveNote(testUserId, any()))
          .thenAnswer((_) async => null);

      // Act
      await repository.unjumbleNote(testUserId, encryptedNote, 'password123');

      // Assert
      verify(() => mockRemoteDataSource.saveNote(
        testUserId,
        any(that: isA<NoteModel>()),
      )).called(1);
    });

    test('should update lock counter on failed password attempt', () async {
      // Arrange
      when(() => mockRemoteDataSource.saveNote(testUserId, any()))
          .thenThrow(ArgumentError('Invalid password'));
      when(() => mockRemoteDataSource.updateLockCounter(testUserId, testNoteId, any()))
          .thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => repository.unjumbleNote(testUserId, encryptedNote, 'wrong_password'),
        throwsA(isArgumentError),
      );
      verify(() => mockRemoteDataSource.updateLockCounter(
        testUserId,
        testNoteId,
        any(that: isA<int>()),
      )).called(1);
    });
  });
} 