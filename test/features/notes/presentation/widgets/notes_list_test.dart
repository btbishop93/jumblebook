import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jumblebook/features/notes/domain/entities/note.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_event.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_state.dart';
import 'package:jumblebook/features/notes/presentation/widgets/notes_list.dart';

// Mock classes
class MockNotesBloc extends Mock implements NotesBloc {}

class MockNavigator extends Mock implements NavigatorState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MockNavigator';
  }
}

class MockBlocStream extends Mock implements Stream<NotesState> {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockNotesBloc mockNotesBloc;
  late MockNavigator mockNavigator;
  late MockBlocStream mockStream;
  final testUserId = 'test-user-id';
  final testNote = Note(
    id: 'test-note-id',
    title: 'Test Note',
    content: 'Test content',
    date: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(LoadNotes(testUserId));
    registerFallbackValue(LoadNote(userId: testUserId, noteId: testNote.id));
    registerFallbackValue(CreateNote(userId: testUserId, note: testNote));
    registerFallbackValue(UpdateNote(userId: testUserId, note: testNote));
    registerFallbackValue(DeleteNote(userId: testUserId, noteId: testNote.id));
    registerFallbackValue(
        JumbleNote(userId: testUserId, note: testNote, password: 'password'));
    registerFallbackValue(
        UnjumbleNote(userId: testUserId, note: testNote, password: 'password'));
    registerFallbackValue(UpdateLockCounter(
        userId: testUserId, noteId: testNote.id, lockCounter: 1));
    registerFallbackValue(StartListeningToNotes(testUserId));
    registerFallbackValue(StopListeningToNotes());
    registerFallbackValue(MaterialPageRoute<void>(builder: (_) => Container()));
  });

  setUp(() {
    mockNotesBloc = MockNotesBloc();
    mockNavigator = MockNavigator();
    mockStream = MockBlocStream();

    // Setup default behaviors
    when(() => mockNotesBloc.state).thenReturn(const NotesInitial());
    when(() => mockNotesBloc.stream).thenAnswer((_) => mockStream);
    when(() => mockStream.listen(any())).thenAnswer(
      (invocation) => Stream<NotesState>.empty().listen((event) {}),
    );

    // Mock event handlers
    when(() => mockNotesBloc.add(any(that: isA<NotesEvent>())))
        .thenAnswer((_) async {});

    // Mock navigation
    when(() => mockNavigator.push(any())).thenAnswer((_) async => null);
    when(() => mockNavigator.pop()).thenAnswer((_) async {});

    // Mock close
    when(() => mockNotesBloc.close()).thenAnswer((_) async {});
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<NotesBloc>.value(
        value: mockNotesBloc,
        child: Builder(
          builder: (context) => Scaffold(
            body: NotesList(userId: testUserId),
          ),
        ),
      ),
    );
  }

  group('NotesList', () {
    testWidgets('should render empty state when no notes',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockNotesBloc.state).thenReturn(const NotesLoaded([]));
      when(() => mockStream.listen(any())).thenAnswer(
        (invocation) => Stream.value(const NotesLoaded([])).listen((event) {}),
      );

      // Act
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Assert
      expect(find.text('No notes found'), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockNotesBloc.state).thenReturn(const NotesLoading());
      when(() => mockStream.listen(any())).thenAnswer(
        (invocation) => Stream.value(const NotesLoading()).listen((event) {}),
      );

      // Act
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display list of notes when loaded',
        (WidgetTester tester) async {
      // Arrange
      final notes = [testNote];
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes));
      when(() => mockStream.listen(any())).thenAnswer(
        (invocation) => Stream.value(NotesLoaded(notes)).listen((event) {}),
      );

      // Act
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Assert
      expect(find.text(testNote.title), findsOneWidget);
    });

    testWidgets('should navigate to note view when note is tapped',
        (WidgetTester tester) async {
      // Arrange
      final notes = [testNote];
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes));
      when(() => mockStream.listen(any())).thenAnswer(
        (invocation) => Stream.value(NotesLoaded(notes)).listen((event) {}),
      );
      final mockObserver = MockNavigatorObserver();

      // Act
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [mockObserver],
        builder: (context, child) {
          return BlocProvider<NotesBloc>.value(
              value: mockNotesBloc, child: child!);
        },
        home: Scaffold(
          body: NotesList(userId: testUserId),
        ),
      ));
      await tester.pump();
      await tester.tap(find.text(testNote.title));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
    });

    testWidgets('should delete note when dismissed',
        (WidgetTester tester) async {
      // Arrange
      final notes = [testNote];
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes));
      when(() => mockStream.listen(any())).thenAnswer(
        (invocation) => Stream.value(NotesLoaded(notes)).listen((event) {}),
      );
      when(() => mockNotesBloc.add(any(that: isA<DeleteNote>())))
          .thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();
      await tester.drag(find.text(testNote.title), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNotesBloc.add(any(that: isA<DeleteNote>()))).called(1);
    });
  });
}
