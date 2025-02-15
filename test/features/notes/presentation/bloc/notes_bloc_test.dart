import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';
import 'package:jumblebook/features/notes/domain/entities/note.dart';
import 'package:jumblebook/features/notes/domain/repositories/notes_repository.dart';
import 'package:jumblebook/features/notes/domain/usecases/usecases.dart' as usecases;
import 'package:jumblebook/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_event.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_state.dart';

class MockGetNotes extends Mock implements usecases.GetNotes {}
class MockSaveNote extends Mock implements usecases.SaveNote {}
class MockDeleteNote extends Mock implements usecases.DeleteNote {}
class MockJumbleNote extends Mock implements usecases.JumbleNote {}
class MockUnjumbleNote extends Mock implements usecases.UnjumbleNote {}
class MockUpdateLockCounter extends Mock implements usecases.UpdateLockCounter {}
class MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  late NotesBloc notesBloc;
  late MockGetNotes mockGetNotes;
  late MockSaveNote mockSaveNote;
  late MockDeleteNote mockDeleteNote;
  late MockJumbleNote mockJumbleNote;
  late MockUnjumbleNote mockUnjumbleNote;
  late MockUpdateLockCounter mockUpdateLockCounter;
  late MockNotesRepository mockNotesRepository;

  final testUserId = 'test-user-id';
  final testNote = Note(
    id: 'test-note-id',
    title: 'Test Note',
    content: 'Test content',
    date: DateTime.now(),
  );

  setUp(() {
    mockGetNotes = MockGetNotes();
    mockSaveNote = MockSaveNote();
    mockDeleteNote = MockDeleteNote();
    mockJumbleNote = MockJumbleNote();
    mockUnjumbleNote = MockUnjumbleNote();
    mockUpdateLockCounter = MockUpdateLockCounter();
    mockNotesRepository = MockNotesRepository();

    notesBloc = NotesBloc(
      getNotes: mockGetNotes,
      saveNote: mockSaveNote,
      deleteNote: mockDeleteNote,
      jumbleNote: mockJumbleNote,
      unjumbleNote: mockUnjumbleNote,
      updateLockCounter: mockUpdateLockCounter,
      notesRepository: mockNotesRepository,
    );
  });

  tearDown(() {
    notesBloc.close();
  });

  test('initial state should be NotesInitial', () {
    expect(notesBloc.state, const NotesInitial());
  });

  group('LoadNotes', () {
    test('emits [NotesLoading, NotesLoaded] when successful', () async {
      // Arrange
      final notes = [testNote];
      when(() => mockNotesRepository.getNotes(testUserId))
          .thenAnswer((_) => Stream.value(notes));

      // Assert
      expect(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          NotesLoaded(notes),
        ]),
      );

      // Act
      notesBloc.add(LoadNotes(testUserId));
    });

    test('emits [NotesLoading, NotesError] when loading fails', () async {
      // Arrange
      final error = Exception('Failed to load notes');
      when(() => mockNotesRepository.getNotes(testUserId))
          .thenAnswer((_) => Stream.error(error));

      // Assert
      expect(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          isA<NotesError>().having(
            (state) => state.errorMessage,
            'error message',
            error.toString(),
          ),
        ]),
      );

      // Act
      notesBloc.add(LoadNotes(testUserId));
    });
  });

  group('LoadNote', () {
    test('emits [NotesLoading, NoteLoaded] when successful', () async {
      // Arrange
      when(() => mockNotesRepository.getNote(testUserId, testNote.id))
          .thenAnswer((_) async => testNote);

      // Assert
      expect(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          NoteLoaded(note: testNote, notes: []),
        ]),
      );

      // Act
      notesBloc.add(LoadNote(userId: testUserId, noteId: testNote.id));
    });

    test('emits [NotesLoading, NotesError] when loading fails', () async {
      // Arrange
      final error = Exception('Failed to load note');
      when(() => mockNotesRepository.getNote(testUserId, testNote.id))
          .thenThrow(error);

      // Assert
      expect(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          isA<NotesError>().having(
            (state) => state.errorMessage,
            'error message',
            error.toString(),
          ),
        ]),
      );

      // Act
      notesBloc.add(LoadNote(userId: testUserId, noteId: testNote.id));
    });
  });

  group('CreateNote', () {
    test('emits [NotesLoading, NotesLoaded] when successful', () async {
      // Arrange
      final notes = [testNote];
      when(() => mockSaveNote(userId: testUserId, note: testNote))
          .thenAnswer((_) async => null);
      when(() => mockNotesRepository.getNotes(testUserId))
          .thenAnswer((_) => Stream.value(notes));

      // Assert
      expect(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          NotesLoaded(notes, selectedNote: testNote),
        ]),
      );

      // Act
      notesBloc.add(CreateNote(userId: testUserId, note: testNote));
    });

    test('emits [NotesLoading, NotesError] when creation fails', () async {
      // Arrange
      final error = Exception('Failed to create note');
      when(() => mockSaveNote(userId: testUserId, note: testNote))
          .thenThrow(error);

      // Assert
      expect(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          isA<NotesError>().having(
            (state) => state.errorMessage,
            'error message',
            error.toString(),
          ),
        ]),
      );

      // Act
      notesBloc.add(CreateNote(userId: testUserId, note: testNote));
    });
  });

  group('UpdateNote', () {
    test('emits [NotesLoading, NotesLoaded] when successful', () async {
      // Arrange
      final notes = [testNote];
      when(() => mockSaveNote(userId: testUserId, note: testNote))
          .thenAnswer((_) async => null);
      when(() => mockNotesRepository.getNotes(testUserId))
          .thenAnswer((_) => Stream.value(notes));

      // Assert
      expect(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          NotesLoaded(notes, selectedNote: testNote),
        ]),
      );

      // Act
      notesBloc.add(UpdateNote(userId: testUserId, note: testNote));
    });

    test('emits [NotesLoading, NotesError] when update fails', () async {
      // Arrange
      final error = Exception('Failed to update note');
      when(() => mockSaveNote(userId: testUserId, note: testNote))
          .thenThrow(error);

      // Assert
      expect(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          isA<NotesError>().having(
            (state) => state.errorMessage,
            'error message',
            error.toString(),
          ),
        ]),
      );

      // Act
      notesBloc.add(UpdateNote(userId: testUserId, note: testNote));
    });
  });

  group('DeleteNote', () {
    test('emits [NotesLoading, NoteDeleted] when successful', () async {
      // Arrange
      final notes = [testNote];
      when(() => mockDeleteNote(userId: testUserId, noteId: testNote.id))
          .thenAnswer((_) async => null);
      when(() => mockNotesRepository.getNotes(testUserId))
          .thenAnswer((_) => Stream.value(notes));

      // Assert
      expect(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          NoteDeleted(notes),
        ]),
      );

      // Act
      notesBloc.add(DeleteNote(userId: testUserId, noteId: testNote.id));
    });

    test('emits [NotesLoading, NotesError] when deletion fails', () async {
      // Arrange
      final error = Exception('Failed to delete note');
      when(() => mockDeleteNote(userId: testUserId, noteId: testNote.id))
          .thenThrow(error);

      // Assert
      expect(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          isA<NotesError>().having(
            (state) => state.errorMessage,
            'error message',
            error.toString(),
          ),
        ]),
      );

      // Act
      notesBloc.add(DeleteNote(userId: testUserId, noteId: testNote.id));
    });
  });

  group('JumbleNote', () {
    final password = 'test-password';
    final jumbledNote = Note(
      id: testNote.id,
      title: testNote.title,
      content: 'jumbled-content',
      date: testNote.date,
      isEncrypted: true,
      password: password,
    );

    test('emits [NotesLoading, NoteJumbled] when successful', () async {
      // Arrange
      when(() => mockJumbleNote(
        userId: testUserId,
        note: testNote,
        password: password,
      )).thenAnswer((_) async => jumbledNote);

      // Assert
      expect(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          NoteJumbled(note: jumbledNote, notes: []),
        ]),
      );

      // Act
      notesBloc.add(JumbleNote(
        userId: testUserId,
        note: testNote,
        password: password,
      ));
    });

    test('emits [NotesLoading, NotesError] when jumbling fails', () async {
      // Arrange
      final error = Exception('Failed to jumble note');
      when(() => mockJumbleNote(
        userId: testUserId,
        note: testNote,
        password: password,
      )).thenThrow(error);

      // Assert
      expect(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          isA<NotesError>().having(
            (state) => state.errorMessage,
            'error message',
            error.toString(),
          ),
        ]),
      );

      // Act
      notesBloc.add(JumbleNote(
        userId: testUserId,
        note: testNote,
        password: password,
      ));
    });
  });

  group('UnjumbleNote', () {
    final password = 'test-password';
    final jumbledNote = Note(
      id: testNote.id,
      title: testNote.title,
      content: 'jumbled-content',
      date: testNote.date,
      isEncrypted: true,
      password: password,
    );

    test('emits [NotesLoading, NoteUnjumbled] when successful', () async {
      // Arrange
      when(() => mockUnjumbleNote(
        userId: testUserId,
        note: jumbledNote,
        password: password,
      )).thenAnswer((_) async => testNote);

      // Assert
      expect(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          NoteUnjumbled(note: testNote, notes: []),
        ]),
      );

      // Act
      notesBloc.add(UnjumbleNote(
        userId: testUserId,
        note: jumbledNote,
        password: password,
      ));
    });

    test('emits [NotesLoading, NotesError] when unjumbling fails', () async {
      // Arrange
      final error = Exception('Failed to unjumble note');
      when(() => mockUnjumbleNote(
        userId: testUserId,
        note: jumbledNote,
        password: password,
      )).thenThrow(error);

      // Assert
      expect(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          isA<NotesError>().having(
            (state) => state.errorMessage,
            'error message',
            error.toString(),
          ),
        ]),
      );

      // Act
      notesBloc.add(UnjumbleNote(
        userId: testUserId,
        note: jumbledNote,
        password: password,
      ));
    });
  });

  group('UpdateLockCounter', () {
    test('emits [NoteLocked] when successful', () async {
      // Arrange
      final lockCounter = 1;
      final lockedNote = testNote.copyWith(lockCounter: lockCounter);
      
      when(() => mockUpdateLockCounter(
        userId: testUserId,
        noteId: testNote.id,
        lockCounter: lockCounter,
      )).thenAnswer((_) async => null);
      when(() => mockNotesRepository.getNote(testUserId, testNote.id))
          .thenAnswer((_) async => lockedNote);

      // Assert
      expect(
        notesBloc.stream,
        emitsInOrder([
          NoteLocked(note: lockedNote, notes: []),
        ]),
      );

      // Act
      notesBloc.add(UpdateLockCounter(
        userId: testUserId,
        noteId: testNote.id,
        lockCounter: lockCounter,
      ));
    });

    test('emits [NotesError] when update fails', () async {
      // Arrange
      final error = Exception('Failed to update lock counter');
      when(() => mockUpdateLockCounter(
        userId: testUserId,
        noteId: testNote.id,
        lockCounter: 1,
      )).thenThrow(error);

      // Assert
      expect(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesError>().having(
            (state) => state.errorMessage,
            'error message',
            error.toString(),
          ),
        ]),
      );

      // Act
      notesBloc.add(UpdateLockCounter(
        userId: testUserId,
        noteId: testNote.id,
        lockCounter: 1,
      ));
    });
  });

  group('StartListeningToNotes', () {
    test('loads initial notes and starts listening', () async {
      // Arrange
      final notes = [testNote];
      when(() => mockGetNotes(testUserId))
          .thenAnswer((_) => Stream.value(notes));

      // Act & Assert
      notesBloc.add(StartListeningToNotes(testUserId));
      
      await expectLater(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          NotesLoaded(notes),
        ]),
      );
    });

    test('handles stream errors', () async {
      // Arrange
      final error = Exception('Stream error');
      when(() => mockGetNotes(testUserId))
          .thenAnswer((_) => Stream.error(error));

      // Act & Assert
      notesBloc.add(StartListeningToNotes(testUserId));
      
      await expectLater(
        notesBloc.stream,
        emitsInOrder([
          isA<NotesLoading>(),
          isA<NotesError>().having(
            (state) => state.errorMessage,
            'error message',
            error.toString(),
          ),
        ]),
      );
    });

    test('processes stream updates', () async {
      // Arrange
      final controller = StreamController<List<Note>>();
      when(() => mockGetNotes(testUserId))
          .thenAnswer((_) => controller.stream);

      // Act & Assert initial state
      notesBloc.add(StartListeningToNotes(testUserId));
      
      await expectLater(
        notesBloc.stream,
        emits(isA<NotesLoading>()),
      );

      // Add notes and verify state updates
      final updatedNotes = [testNote];
      controller.add(updatedNotes);
      
      await expectLater(
        notesBloc.stream,
        emits(NotesLoaded(updatedNotes)),
      );

      // Clean up
      await controller.close();
    });
  });

  group('StopListeningToNotes', () {
    test('stops listening to note changes', () async {
      // Arrange
      final controller = StreamController<List<Note>>();
      when(() => mockGetNotes(testUserId))
          .thenAnswer((_) => controller.stream);

      // Act
      notesBloc.add(StartListeningToNotes(testUserId));
      await Future.delayed(const Duration(milliseconds: 100));
      notesBloc.add(StopListeningToNotes());
      await Future.delayed(const Duration(milliseconds: 100));

      // Try to add more data after stopping
      controller.add([testNote]);

      // Assert - No new states should be emitted after stopping
      await expectLater(
        notesBloc.stream,
        emitsInOrder([]),
      );

      // Clean up
      await controller.close();
    });
  });
} 