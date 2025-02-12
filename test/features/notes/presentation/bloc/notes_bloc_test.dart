import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/notes/domain/entities/note.dart';
import 'package:jumblebook/features/notes/domain/repositories/notes_repository.dart';
import 'package:jumblebook/features/notes/domain/usecases/usecases.dart' as usecases;
import 'package:jumblebook/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_event.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_state.dart';

class MockNotesRepository extends Mock implements NotesRepository {}
class MockGetNotes extends Mock implements usecases.GetNotes {}
class MockSaveNote extends Mock implements usecases.SaveNote {}
class MockDeleteNote extends Mock implements usecases.DeleteNote {}
class MockEncryptNote extends Mock implements usecases.EncryptNote {}
class MockDecryptNote extends Mock implements usecases.DecryptNote {}
class MockUpdateLockCounter extends Mock implements usecases.UpdateLockCounter {}

// Register fallback values for Mocktail
class FakeNote extends Fake implements Note {}

void main() {
  late NotesBloc notesBloc;
  late MockNotesRepository notesRepository;
  late MockGetNotes getNotes;
  late MockSaveNote saveNote;
  late MockDeleteNote deleteNote;
  late MockEncryptNote encryptNote;
  late MockDecryptNote decryptNote;
  late MockUpdateLockCounter updateLockCounter;

  // Test note fixtures
  final testNote = Note(
    id: 'test-id',
    title: 'Test Note',
    content: 'Test content',
    date: DateTime(2024),
  );

  final encryptedNote = Note(
    id: 'test-id',
    title: 'Test Note',
    content: 'Encrypted content',
    isEncrypted: true,
    password: 'password123',
    decryptShift: 3,
    date: DateTime(2024),
  );

  final testNotes = [
    testNote,
    Note(
      id: 'test-id-2',
      title: 'Test Note 2',
      content: 'Test content 2',
      date: DateTime(2024),
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeNote());
  });

  setUp(() {
    notesRepository = MockNotesRepository();
    getNotes = MockGetNotes();
    saveNote = MockSaveNote();
    deleteNote = MockDeleteNote();
    encryptNote = MockEncryptNote();
    decryptNote = MockDecryptNote();
    updateLockCounter = MockUpdateLockCounter();

    notesBloc = NotesBloc(
      getNotes: getNotes,
      saveNote: saveNote,
      deleteNote: deleteNote,
      encryptNote: encryptNote,
      decryptNote: decryptNote,
      updateLockCounter: updateLockCounter,
      notesRepository: notesRepository,
    );
  });

  tearDown(() {
    notesBloc.close();
  });

  test('initial state is NotesInitial', () {
    expect(notesBloc.state, isA<NotesInitial>());
  });

  group('LoadNotes', () {
    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesLoaded] when notes are loaded successfully',
      build: () {
        when(() => notesRepository.getNotes(any()))
            .thenAnswer((_) => Stream.value(testNotes));
        return notesBloc;
      },
      act: (bloc) => bloc.add(const LoadNotes('user-id')),
      expect: () => [
        const NotesLoading(),
        NotesLoaded(testNotes),
      ],
      verify: (_) {
        verify(() => notesRepository.getNotes('user-id')).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesError] when loading fails',
      build: () {
        when(() => notesRepository.getNotes(any()))
            .thenAnswer((_) => Stream.error('Failed to load notes'));
        return notesBloc;
      },
      act: (bloc) => bloc.add(const LoadNotes('user-id')),
      expect: () => [
        const NotesLoading(),
        const NotesError('Failed to load notes'),
      ],
    );
  });

  group('LoadNote', () {
    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NoteLoaded] when note is loaded successfully',
      build: () {
        when(() => notesRepository.getNote(any(), any()))
            .thenAnswer((_) async => testNote);
        return notesBloc;
      },
      act: (bloc) => bloc.add(const LoadNote(
        userId: 'user-id',
        noteId: 'test-id',
      )),
      expect: () => [
        const NotesLoading(),
        NoteLoaded(note: testNote, notes: const []),
      ],
      verify: (_) {
        verify(() => notesRepository.getNote('user-id', 'test-id')).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesError] when loading fails',
      build: () {
        when(() => notesRepository.getNote(any(), any()))
            .thenThrow('Failed to load note');
        return notesBloc;
      },
      act: (bloc) => bloc.add(const LoadNote(
        userId: 'user-id',
        noteId: 'test-id',
      )),
      expect: () => [
        const NotesLoading(),
        const NotesError('Failed to load note'),
      ],
    );
  });

  group('CreateNote', () {
    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesLoaded] when note is created successfully',
      build: () {
        when(() => saveNote.call(
          userId: any(named: 'userId'),
          note: any(named: 'note'),
        )).thenAnswer((_) async => null);
        when(() => notesRepository.getNotes(any()))
            .thenAnswer((_) => Stream.value(testNotes));
        return notesBloc;
      },
      act: (bloc) => bloc.add(CreateNote(
        userId: 'user-id',
        note: testNote,
      )),
      expect: () => [
        const NotesLoading(),
        NotesLoaded(testNotes, selectedNote: testNote),
      ],
      verify: (_) {
        verify(() => saveNote.call(
          userId: 'user-id',
          note: testNote,
        )).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesError] when creation fails',
      build: () {
        when(() => saveNote.call(
          userId: any(named: 'userId'),
          note: any(named: 'note'),
        )).thenThrow('Failed to create note');
        return notesBloc;
      },
      act: (bloc) => bloc.add(CreateNote(
        userId: 'user-id',
        note: testNote,
      )),
      expect: () => [
        const NotesLoading(),
        const NotesError('Failed to create note'),
      ],
    );
  });

  group('UpdateNote', () {
    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesLoaded] when note is updated successfully',
      build: () {
        when(() => saveNote.call(
          userId: any(named: 'userId'),
          note: any(named: 'note'),
        )).thenAnswer((_) async => null);
        when(() => notesRepository.getNotes(any()))
            .thenAnswer((_) => Stream.value(testNotes));
        return notesBloc;
      },
      act: (bloc) => bloc.add(UpdateNote(
        userId: 'user-id',
        note: testNote,
      )),
      expect: () => [
        const NotesLoading(),
        NotesLoaded(testNotes, selectedNote: testNote),
      ],
      verify: (_) {
        verify(() => saveNote.call(
          userId: 'user-id',
          note: testNote,
        )).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesError] when update fails',
      build: () {
        when(() => saveNote.call(
          userId: any(named: 'userId'),
          note: any(named: 'note'),
        )).thenThrow('Failed to update note');
        return notesBloc;
      },
      act: (bloc) => bloc.add(UpdateNote(
        userId: 'user-id',
        note: testNote,
      )),
      expect: () => [
        const NotesLoading(),
        const NotesError('Failed to update note'),
      ],
    );
  });

  group('DeleteNote', () {
    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NoteDeleted] when note is deleted successfully',
      build: () {
        when(() => deleteNote.call(
          userId: any(named: 'userId'),
          noteId: any(named: 'noteId'),
        )).thenAnswer((_) async => null);
        when(() => notesRepository.getNotes(any()))
            .thenAnswer((_) => Stream.value(testNotes));
        return notesBloc;
      },
      act: (bloc) => bloc.add(const DeleteNote(
        userId: 'user-id',
        noteId: 'test-id',
      )),
      expect: () => [
        const NotesLoading(),
        NoteDeleted(testNotes),
      ],
      verify: (_) {
        verify(() => deleteNote.call(
          userId: 'user-id',
          noteId: 'test-id',
        )).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesError] when deletion fails',
      build: () {
        when(() => deleteNote.call(
          userId: any(named: 'userId'),
          noteId: any(named: 'noteId'),
        )).thenThrow('Failed to delete note');
        return notesBloc;
      },
      act: (bloc) => bloc.add(const DeleteNote(
        userId: 'user-id',
        noteId: 'test-id',
      )),
      expect: () => [
        const NotesLoading(),
        const NotesError('Failed to delete note'),
      ],
    );
  });

  group('EncryptNote', () {
    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NoteEncrypted] when note is encrypted successfully',
      build: () {
        when(() => encryptNote.call(
          note: any(named: 'note'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => encryptedNote);
        return notesBloc;
      },
      act: (bloc) => bloc.add(EncryptNote(
        note: testNote,
        password: 'password123',
      )),
      expect: () => [
        const NotesLoading(),
        NoteEncrypted(note: encryptedNote, notes: const []),
      ],
      verify: (_) {
        verify(() => encryptNote.call(
          note: testNote,
          password: 'password123',
        )).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesError] when encryption fails',
      build: () {
        when(() => encryptNote.call(
          note: any(named: 'note'),
          password: any(named: 'password'),
        )).thenThrow('Failed to encrypt note');
        return notesBloc;
      },
      act: (bloc) => bloc.add(EncryptNote(
        note: testNote,
        password: 'password123',
      )),
      expect: () => [
        const NotesLoading(),
        const NotesError('Failed to encrypt note'),
      ],
    );
  });

  group('DecryptNote', () {
    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NoteDecrypted] when note is decrypted successfully',
      build: () {
        when(() => decryptNote.call(
          note: any(named: 'note'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => testNote);
        return notesBloc;
      },
      act: (bloc) => bloc.add(DecryptNote(
        note: encryptedNote,
        password: 'password123',
      )),
      expect: () => [
        const NotesLoading(),
        NoteDecrypted(note: testNote, notes: const []),
      ],
      verify: (_) {
        verify(() => decryptNote.call(
          note: encryptedNote,
          password: 'password123',
        )).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NotesLoading, NotesError] when decryption fails',
      build: () {
        when(() => decryptNote.call(
          note: any(named: 'note'),
          password: any(named: 'password'),
        )).thenThrow('Failed to decrypt note');
        return notesBloc;
      },
      act: (bloc) => bloc.add(DecryptNote(
        note: encryptedNote,
        password: 'wrong-password',
      )),
      expect: () => [
        const NotesLoading(),
        const NotesError('Failed to decrypt note'),
      ],
    );
  });

  group('UpdateLockCounter', () {
    blocTest<NotesBloc, NotesState>(
      'emits [NoteLocked] when lock counter is updated successfully',
      build: () {
        when(() => updateLockCounter.call(
          userId: any(named: 'userId'),
          noteId: any(named: 'noteId'),
          lockCounter: any(named: 'lockCounter'),
        )).thenAnswer((_) async => null);
        when(() => notesRepository.getNote(any(), any()))
            .thenAnswer((_) async => testNote);
        return notesBloc;
      },
      act: (bloc) => bloc.add(const UpdateLockCounter(
        userId: 'user-id',
        noteId: 'test-id',
        lockCounter: 1,
      )),
      expect: () => [
        NoteLocked(note: testNote, notes: const []),
      ],
      verify: (_) {
        verify(() => updateLockCounter.call(
          userId: 'user-id',
          noteId: 'test-id',
          lockCounter: 1,
        )).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'emits [NotesError] when lock counter update fails',
      build: () {
        when(() => updateLockCounter.call(
          userId: any(named: 'userId'),
          noteId: any(named: 'noteId'),
          lockCounter: any(named: 'lockCounter'),
        )).thenThrow('Failed to update lock counter');
        return notesBloc;
      },
      act: (bloc) => bloc.add(const UpdateLockCounter(
        userId: 'user-id',
        noteId: 'test-id',
        lockCounter: 1,
      )),
      expect: () => [
        const NotesError('Failed to update lock counter'),
      ],
    );
  });

  group('Notes Subscription', () {
    blocTest<NotesBloc, NotesState>(
      'starts listening to notes changes',
      build: () {
        when(() => getNotes.call(any()))
            .thenAnswer((_) => Stream.value(testNotes));
        when(() => notesRepository.getNotes(any()))
            .thenAnswer((_) => Stream.value(testNotes));
        return notesBloc;
      },
      act: (bloc) => bloc.add(const StartListeningToNotes('user-id')),
      verify: (_) {
        verify(() => getNotes.call('user-id')).called(1);
      },
    );

    blocTest<NotesBloc, NotesState>(
      'stops listening to notes changes',
      build: () {
        when(() => getNotes.call(any()))
            .thenAnswer((_) => Stream.value(testNotes));
        return notesBloc;
      },
      act: (bloc) async {
        bloc.add(const StartListeningToNotes('user-id'));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(StopListeningToNotes());
      },
      wait: const Duration(milliseconds: 20),
      verify: (_) {
        verify(() => getNotes.call('user-id')).called(1);
      },
    );
  });
} 