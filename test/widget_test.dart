// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/core/theme/bloc/theme_bloc.dart';
import 'package:jumblebook/core/theme/bloc/theme_event.dart';
import 'package:jumblebook/core/theme/bloc/theme_state.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_event.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_state.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_state.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_event.dart';
import 'package:jumblebook/features/notes/domain/entities/note.dart';
import 'package:jumblebook/main.dart';

// Mock classes
class MockAuthBloc extends Mock implements AuthBloc {}

class MockNotesBloc extends Mock implements NotesBloc {}

class MockThemeBloc extends Mock implements ThemeBloc {}

class MockAuthStream extends Mock implements Stream<AuthState> {}

class MockNotesStream extends Mock implements Stream<NotesState> {}

class MockThemeStream extends Mock implements Stream<ThemeState> {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockNotesBloc mockNotesBloc;
  late MockThemeBloc mockThemeBloc;
  late MockAuthStream mockAuthStream;
  late MockNotesStream mockNotesStream;
  late MockThemeStream mockThemeStream;

  final testUserId = 'test-user-id';
  final testNote = Note(
    id: 'test-note-id',
    title: 'Test Note',
    content: 'Test content',
    date: DateTime.now(),
  );

  setUpAll(() {
    // Auth Events
    registerFallbackValue(SignInWithEmailRequested(
        email: 'test@email.com', password: 'password'));
    registerFallbackValue(SignUpWithEmailRequested(
        email: 'test@email.com', password: 'password'));
    registerFallbackValue(SignOutRequested());
    registerFallbackValue(CheckAuthStatus());

    // Theme Events
    registerFallbackValue(const ChangeThemeEvent(ThemeMode.system));

    // Notes Events
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
    mockAuthBloc = MockAuthBloc();
    mockNotesBloc = MockNotesBloc();
    mockThemeBloc = MockThemeBloc();
    mockAuthStream = MockAuthStream();
    mockNotesStream = MockNotesStream();
    mockThemeStream = MockThemeStream();

    // Setup auth bloc
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer((_) => mockAuthStream);
    when(() => mockAuthStream.listen(any())).thenAnswer(
      (invocation) => Stream<AuthState>.empty().listen((event) {}),
    );
    when(() => mockAuthBloc.add(any(that: isA<AuthEvent>())))
        .thenAnswer((_) async {});
    when(() => mockAuthBloc.close()).thenAnswer((_) async {});

    // Setup notes bloc
    when(() => mockNotesBloc.state).thenReturn(NotesInitial());
    when(() => mockNotesBloc.stream).thenAnswer((_) => mockNotesStream);
    when(() => mockNotesStream.listen(any())).thenAnswer(
      (invocation) => Stream<NotesState>.empty().listen((event) {}),
    );
    when(() => mockNotesBloc.add(any(that: isA<NotesEvent>())))
        .thenAnswer((_) async {});
    when(() => mockNotesBloc.close()).thenAnswer((_) async {});

    // Setup theme bloc
    when(() => mockThemeBloc.state).thenReturn(ThemeState());
    when(() => mockThemeBloc.stream).thenAnswer((_) => mockThemeStream);
    when(() => mockThemeStream.listen(any())).thenAnswer(
      (invocation) => Stream<ThemeState>.empty().listen((event) {}),
    );
    when(() => mockThemeBloc.add(any(that: isA<ThemeEvent>())))
        .thenAnswer((_) async {});
    when(() => mockThemeBloc.close()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
        ),
        BlocProvider<NotesBloc>.value(
          value: mockNotesBloc,
        ),
        BlocProvider<ThemeBloc>.value(
          value: mockThemeBloc,
        ),
      ],
      child: MyApp(),
    );
  }

  group('App', () {
    testWidgets('should render without errors', (WidgetTester tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());
      when(() => mockAuthStream.listen(any())).thenAnswer(
        (invocation) => Stream.value(AuthInitial()).listen((event) {}),
      );

      when(() => mockNotesBloc.state).thenReturn(NotesInitial());
      when(() => mockNotesStream.listen(any())).thenAnswer(
        (invocation) => Stream.value(NotesInitial()).listen((event) {}),
      );

      when(() => mockThemeBloc.state).thenReturn(ThemeState());
      when(() => mockThemeStream.listen(any())).thenAnswer(
        (invocation) => Stream.value(ThemeState()).listen((event) {}),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
