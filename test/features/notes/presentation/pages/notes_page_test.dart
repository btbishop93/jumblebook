import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';
import 'package:jumblebook/features/notes/domain/entities/note.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_event.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_state.dart';
import 'package:jumblebook/features/notes/presentation/pages/notes_page.dart';
import 'package:jumblebook/features/notes/presentation/widgets/notes_list.dart';
import 'package:jumblebook/features/notes/presentation/widgets/note_view.dart';
import 'package:jumblebook/features/authentication/domain/entities/user.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_state.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_data.dart';

// Mock classes
class MockNotesBloc extends Mock implements NotesBloc {}

class MockAuthBloc extends Mock implements AuthBloc {
  final _controller = StreamController<AuthState>.broadcast();

  @override
  Stream<AuthState> get stream => _controller.stream;

  @override
  Future<void> close() async {
    await _controller.close();
  }

  @override
  void emit(AuthState state) {
    _controller.add(state);
  }
}

class MockBlocStream extends Mock implements Stream<NotesState> {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockNotesBloc mockNotesBloc;
  late MockAuthBloc mockAuthBloc;
  late MockBlocStream mockStream;
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
    mockAuthBloc = MockAuthBloc();
    mockStream = MockBlocStream();

    // Setup default behaviors
    when(() => mockNotesBloc.state).thenReturn(const NotesInitial());
    when(() => mockNotesBloc.stream).thenAnswer((_) => mockStream);
    when(() => mockStream.listen(any())).thenAnswer(
      (invocation) => Stream<NotesState>.empty().listen((event) {}),
    );

    // Setup AuthBloc default behavior
    final authState = Authenticated(AuthData(user: testUser));
    when(() => mockAuthBloc.state).thenReturn(authState);
    mockAuthBloc.emit(authState);

    // Mock event handlers
    when(() => mockNotesBloc.add(any(that: isA<NotesEvent>())))
        .thenAnswer((_) async {});

    // Mock close
    when(() => mockNotesBloc.close()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<NotesBloc>.value(value: mockNotesBloc),
            BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          ],
          child: child!,
        );
      },
      home: NotesPage(currentUser: testUser),
    );
  }

  group('NotesPage', () {
    testWidgets('should render initial empty state',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockNotesBloc.state).thenReturn(const NotesLoaded([]));
      when(() => mockStream.listen(any())).thenAnswer(
        (invocation) => Stream.value(const NotesLoaded([])).listen((event) {}),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('No notes found'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      verify(() => mockNotesBloc.add(any(that: isA<StartListeningToNotes>())))
          .called(1);
    });

    testWidgets('should show loading indicator when loading notes',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockNotesBloc.state).thenReturn(NotesLoading(notes: const []));
      when(() => mockStream.listen(any())).thenAnswer(
        (invocation) =>
            Stream.value(NotesLoading(notes: const [])).listen((event) {}),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when loading fails',
        (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load notes';
      when(() => mockNotesBloc.state)
          .thenReturn(const NotesError(errorMessage));
      when(() => mockStream.listen(any())).thenAnswer(
        (invocation) =>
            Stream.value(const NotesError(errorMessage)).listen((event) {}),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should navigate to note view when FAB is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockNotesBloc.state).thenReturn(const NotesLoaded([]));
      when(() => mockStream.listen(any())).thenAnswer(
        (invocation) => Stream.value(const NotesLoaded([])).listen((event) {}),
      );
      final mockObserver = MockNavigatorObserver();

      // Act
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [mockObserver],
        builder: (context, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<NotesBloc>.value(value: mockNotesBloc),
              BlocProvider<AuthBloc>.value(value: mockAuthBloc),
            ],
            child: child!,
          );
        },
        home: NotesPage(currentUser: testUser),
      ));
      await tester.pump();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
    });

    testWidgets('should display notes list when notes are loaded',
        (WidgetTester tester) async {
      // Arrange
      final notes = [testNote];
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes));
      when(() => mockStream.listen(any())).thenAnswer(
        (invocation) => Stream.value(NotesLoaded(notes)).listen((event) {}),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(NotesList), findsOneWidget);
      expect(find.text(testNote.title), findsOneWidget);
    });

    testWidgets('should open note creation dialog when FAB is pressed',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(const []));
      when(() => mockStream.listen(any())).thenAnswer(
        (invocation) => Stream.value(NotesLoaded(const [])).listen((event) {}),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(NoteView), findsOneWidget);
      expect(
          find.byType(TextField), findsNWidgets(2)); // Title and content fields
    });

    testWidgets('should create note when form is submitted',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(const []));
      when(() => mockStream.listen(any())).thenAnswer(
        (invocation) => Stream.value(NotesLoaded(const [])).listen((event) {}),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'New Title');
      await tester.enterText(find.byType(TextField).last, 'New Content');

      // Unfocus to trigger save
      await tester.tap(find.byType(Scaffold).first);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNotesBloc.add(any(that: isA<CreateNote>()))).called(1);
      verify(() => mockNotesBloc.add(any(that: isA<UpdateNote>()))).called(4);
    });

    testWidgets('should open note view when note is tapped',
        (WidgetTester tester) async {
      // Arrange
      final notes = [testNote];
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes));
      when(() => mockStream.listen(any())).thenAnswer(
        (invocation) => Stream.value(NotesLoaded(notes)).listen((event) {}),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.tap(find.text(testNote.title));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(NoteView), findsOneWidget);
      expect(find.text(testNote.title), findsOneWidget);
      expect(find.text(testNote.content), findsOneWidget);
    });

    testWidgets('should delete note when swiped', (WidgetTester tester) async {
      // Arrange
      final notes = [testNote];
      when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes));
      when(() => mockStream.listen(any())).thenAnswer(
        (invocation) => Stream.value(NotesLoaded(notes)).listen((event) {}),
      );
      when(() => mockNotesBloc.add(any(that: isA<DeleteNote>())))
          .thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.drag(find.text(testNote.title), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNotesBloc.add(any(that: isA<DeleteNote>()))).called(1);
    });
  });
}
