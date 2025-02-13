import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/notes/domain/entities/note.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_event.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_state.dart';
import 'package:jumblebook/features/notes/presentation/pages/notes_page.dart';
import 'package:jumblebook/features/notes/presentation/widgets/notes_list.dart';
import 'package:jumblebook/features/notes/presentation/widgets/note_view.dart';
import 'package:jumblebook/features/authentication/domain/entities/user.dart';

class MockNotesBloc extends Mock implements NotesBloc {}

void main() {
  late MockNotesBloc mockNotesBloc;
  final testUserId = 'test-user-id';
  final testUser = User(
    id: testUserId,
    email: 'test@example.com',
    displayName: 'Test User',
  );
  final testNote = Note(
    id: 'test-note-id',
    title: 'Test Note',
    content: 'Test content',
    date: DateTime.now(),
  );

  setUp(() {
    mockNotesBloc = MockNotesBloc();
    
    // Register fallback values for events
    registerFallbackValue(LoadNotes(testUserId));
    registerFallbackValue(CreateNote(userId: testUserId, note: testNote));
    registerFallbackValue(DeleteNote(userId: testUserId, noteId: testNote.id));
    
    // Default state
    when(() => mockNotesBloc.state).thenReturn(const NotesInitial());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<NotesBloc>(
        create: (context) => mockNotesBloc,
        child: NotesPage(currentUser: testUser),
      ),
    );
  }

  group('NotesPage', () {
    testWidgets('should render initial empty state', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotesBloc.state).thenReturn(const NotesInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('No notes yet'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading notes', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotesBloc.state).thenReturn(NotesLoading(notes: const []));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display notes list when notes are loaded', (WidgetTester tester) async {
      // Arrange
      final notes = [testNote];
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(NotesList), findsOneWidget);
      expect(find.text(testNote.title), findsOneWidget);
    });

    testWidgets('should show error message when loading fails', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotesBloc.state).thenReturn(NotesError('Failed to load notes', notes: const []));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Failed to load notes'), findsOneWidget);
    });

    testWidgets('should open note creation dialog when FAB is pressed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(NoteView), findsOneWidget);
      expect(find.text(''), findsOneWidget); // Empty title for new note
    });

    testWidgets('should create note when form is submitted', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Open create note dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill in form
      await tester.enterText(
        find.byType(TextFormField).first,
        'New Note Title',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'New Note Content',
      );

      // Submit form
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNotesBloc.add(any(that: isA<CreateNote>()))).called(1);
    });

    testWidgets('should open note view when note is tapped', (WidgetTester tester) async {
      // Arrange
      final notes = [testNote];
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text(testNote.title));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(NoteView), findsOneWidget);
      expect(find.text(testNote.title), findsOneWidget);
      expect(find.text(testNote.content), findsOneWidget);
    });

    testWidgets('should delete note when delete is confirmed', (WidgetTester tester) async {
      // Arrange
      final notes = [testNote];
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Open note options
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      
      // Tap delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      
      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNotesBloc.add(any(that: isA<DeleteNote>()))).called(1);
    });

    testWidgets('should start listening to notes on init', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      verify(() => mockNotesBloc.add(StartListeningToNotes(testUserId))).called(1);
    });

    testWidgets('should stop listening to notes on dispose', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.pumpWidget(const SizedBox());

      // Assert
      verify(() => mockNotesBloc.add(StopListeningToNotes())).called(1);
    });
  });
} 