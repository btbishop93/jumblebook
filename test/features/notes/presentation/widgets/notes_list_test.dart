import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/notes/domain/entities/note.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_event.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_state.dart';
import 'package:jumblebook/features/notes/presentation/widgets/notes_list.dart';
import 'package:jumblebook/features/notes/presentation/widgets/note_view.dart';

class MockNotesBloc extends Mock implements NotesBloc {}

void main() {
  late MockNotesBloc mockNotesBloc;
  final testUserId = 'test-user-id';
  final testNote = Note(
    id: 'test-note-id',
    title: 'Test Note',
    content: 'Test content',
    date: DateTime.now(),
  );

  setUp(() {
    mockNotesBloc = MockNotesBloc();
    when(() => mockNotesBloc.state).thenReturn(const NotesInitial());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<NotesBloc>(
        create: (context) => mockNotesBloc,
        child: NotesList(userId: testUserId),
      ),
    );
  }

  group('NotesList', () {
    testWidgets('should render empty state when no notes', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(const []));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('No notes yet'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotesBloc.state).thenReturn(NotesLoading(notes: const []));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display list of notes when loaded', (WidgetTester tester) async {
      // Arrange
      final notes = [testNote];
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text(testNote.title), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('should show error message when loading fails', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotesBloc.state).thenReturn(NotesError('Failed to load notes', notes: const []));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Failed to load notes'), findsOneWidget);
    });

    testWidgets('should navigate to note view when note is tapped', (WidgetTester tester) async {
      // Arrange
      final notes = [testNote];
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text(testNote.title));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(NoteView), findsOneWidget);
    });

    testWidgets('should show note options when more button is tapped', (WidgetTester tester) async {
      // Arrange
      final notes = [testNote];
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should show delete confirmation dialog', (WidgetTester tester) async {
      // Arrange
      final notes = [testNote];
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Delete Note'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this note?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should delete note when confirmed', (WidgetTester tester) async {
      // Arrange
      final notes = [testNote];
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNotesBloc.add(DeleteNote(
        userId: testUserId,
        noteId: testNote.id,
      ))).called(1);
    });

    testWidgets('should not delete note when cancelled', (WidgetTester tester) async {
      // Arrange
      final notes = [testNote];
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      verifyNever(() => mockNotesBloc.add(any()));
    });
  });
} 