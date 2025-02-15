import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/notes/domain/entities/note.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_event.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_state.dart';
import 'package:jumblebook/features/notes/presentation/widgets/note_view.dart';

// Mock classes
class MockNotesBloc extends Mock implements NotesBloc {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockNotesBloc mockNotesBloc;
  final testUserId = 'test-user-id';
  final testNote = Note(
    id: 'test-note-id',
    title: 'Test Note',
    content: 'Test content',
    date: DateTime.now(),
  );
  final encryptedNote = Note(
    id: 'test-note-id',
    title: 'Test Note',
    content: 'Encrypted content',
    isEncrypted: true,
    lockCounter: 0,
    date: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(LoadNotes(testUserId));
    registerFallbackValue(LoadNote(userId: testUserId, noteId: testNote.id));
    registerFallbackValue(CreateNote(userId: testUserId, note: testNote));
    registerFallbackValue(UpdateNote(userId: testUserId, note: testNote));
    registerFallbackValue(DeleteNote(userId: testUserId, noteId: testNote.id));
    registerFallbackValue(JumbleNote(userId: testUserId, note: testNote, password: 'password'));
    registerFallbackValue(UnjumbleNote(userId: testUserId, note: testNote, password: 'password'));
    registerFallbackValue(UpdateLockCounter(userId: testUserId, noteId: testNote.id, lockCounter: 1));
    registerFallbackValue(StartListeningToNotes(testUserId));
    registerFallbackValue(StopListeningToNotes());
    registerFallbackValue(MaterialPageRoute<void>(builder: (_) => Container()));
  });

  setUp(() {
    mockNotesBloc = MockNotesBloc();
  });

  Widget createWidgetUnderTest({
    Note? note,
    required StreamController<NotesState> streamController,
  }) {
    final currentNote = note ?? testNote;
    
    // Setup default behaviors for each test
    when(() => mockNotesBloc.state).thenReturn(NotesLoaded([currentNote]));
    when(() => mockNotesBloc.stream).thenAnswer((_) => streamController.stream.asBroadcastStream());
    when(() => mockNotesBloc.add(any(that: isA<NotesEvent>()))).thenAnswer((_) async {});
    when(() => mockNotesBloc.close()).thenAnswer((_) async {});

    return MaterialApp(
      home: BlocProvider<NotesBloc>.value(
        value: mockNotesBloc,
        child: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  key: const Key('lock_button'),
                  icon: const Icon(Icons.lock),
                  onPressed: () {
                    if (!currentNote.isEncrypted) {
                      mockNotesBloc.add(JumbleNote(
                        userId: testUserId,
                        note: currentNote,
                        password: 'password123',
                      ));
                    } else {
                      mockNotesBloc.add(UnjumbleNote(
                        userId: testUserId,
                        note: currentNote,
                        password: 'password123',
                      ));
                    }
                  },
                ),
              ],
            ),
            body: NoteView(
              userId: testUserId,
              note: currentNote,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pumpAndWaitForLoadNote(WidgetTester tester, StreamController<NotesState> streamController, Note note) async {
    await tester.pumpWidget(createWidgetUnderTest(
      note: note,
      streamController: streamController,
    ));
    
    // Wait for LoadNote to complete
    await tester.pump();
    streamController.add(NoteLoaded(note: note, notes: [note]));
    await tester.pumpAndSettle();
  }

  group('NoteView', () {
    testWidgets('should update note when title is changed', (WidgetTester tester) async {
      final streamController = StreamController<NotesState>.broadcast();
      addTearDown(streamController.close);

      // Arrange
      when(() => mockNotesBloc.add(any(that: isA<LoadNote>()))).thenAnswer((_) async {
        streamController.add(NoteLoaded(note: testNote, notes: [testNote]));
      });

      // Act
      await pumpAndWaitForLoadNote(tester, streamController, testNote);
      
      // Find and interact with title field
      final titleField = find.byType(TextField).first;
      await tester.tap(titleField);
      await tester.pump(); // Wait for focus
      await tester.enterText(titleField, 'Updated Title');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 600)); // Wait for debounce

      // Assert
      verify(() => mockNotesBloc.add(any(that: isA<UpdateNote>()))).called(1);
    });

    testWidgets('should update note when content is changed', (WidgetTester tester) async {
      final streamController = StreamController<NotesState>.broadcast();
      addTearDown(streamController.close);

      // Arrange
      when(() => mockNotesBloc.add(any(that: isA<LoadNote>()))).thenAnswer((_) async {
        streamController.add(NoteLoaded(note: testNote, notes: [testNote]));
      });

      // Act
      await pumpAndWaitForLoadNote(tester, streamController, testNote);
      
      // Find and interact with content field
      final contentField = find.byType(TextField).last;
      await tester.tap(contentField);
      await tester.pump(); // Wait for focus
      await tester.enterText(contentField, 'Updated content');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 600)); // Wait for debounce

      // Assert
      verify(() => mockNotesBloc.add(any(that: isA<UpdateNote>()))).called(1);
    });

    testWidgets('should encrypt note when lock button is tapped', (WidgetTester tester) async {
      final streamController = StreamController<NotesState>.broadcast();
      addTearDown(streamController.close);

      // Arrange
      when(() => mockNotesBloc.add(any(that: isA<LoadNote>()))).thenAnswer((_) async {
        streamController.add(NoteLoaded(note: testNote, notes: [testNote]));
      });

      // Act
      await pumpAndWaitForLoadNote(tester, streamController, testNote);
      
      // Find and tap the lock button
      final lockButton = find.byKey(const Key('lock_button'));
      await tester.tap(lockButton);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNotesBloc.add(any(that: isA<JumbleNote>()))).called(1);
    });

    testWidgets('should decrypt note when lock button is tapped', (WidgetTester tester) async {
      final streamController = StreamController<NotesState>.broadcast();
      addTearDown(streamController.close);

      // Arrange
      when(() => mockNotesBloc.add(any(that: isA<LoadNote>()))).thenAnswer((_) async {
        streamController.add(NoteLoaded(note: encryptedNote, notes: [encryptedNote]));
      });

      // Act
      await pumpAndWaitForLoadNote(tester, streamController, encryptedNote);
      
      // Find and tap the lock button
      final lockButton = find.byKey(const Key('lock_button'));
      await tester.tap(lockButton);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNotesBloc.add(any(that: isA<UnjumbleNote>()))).called(1);
    });
  });
} 