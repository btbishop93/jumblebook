import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/notes/domain/entities/note.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_event.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_state.dart';
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

  Widget createWidgetUnderTest({
    required Note note,
    bool isNewNote = false,
  }) {
    return MaterialApp(
      home: BlocProvider<NotesBloc>(
        create: (context) => mockNotesBloc,
        child: NoteView(
          userId: testUserId,
          note: note,
          isNewNote: isNewNote,
        ),
      ),
    );
  }

  group('NoteView', () {
    testWidgets('should render note title and content', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(note: testNote));

      // Assert
      expect(find.text(testNote.title), findsOneWidget);
      expect(find.text(testNote.content), findsOneWidget);
    });

    testWidgets('should update note when text changes', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(note: testNote));

      // Act - Update title
      await tester.enterText(
        find.byType(TextFormField).first,
        'Updated Title',
      );
      await tester.pump();

      // Update content
      await tester.enterText(
        find.byType(TextFormField).last,
        'Updated content',
      );
      await tester.pump();

      // Save note
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNotesBloc.add(any(that: isA<UpdateNote>()))).called(1);
    });

    testWidgets('should create new note when isNewNote is true', (WidgetTester tester) async {
      // Arrange
      final newNote = Note(
        id: 'new-note-id',
        title: '',
        content: '',
        date: DateTime.now(),
      );
      await tester.pumpWidget(createWidgetUnderTest(
        note: newNote,
        isNewNote: true,
      ));

      // Act - Enter note details
      await tester.enterText(
        find.byType(TextFormField).first,
        'New Note Title',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'New note content',
      );
      await tester.pump();

      // Save note
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNotesBloc.add(any(that: isA<CreateNote>()))).called(1);
    });

    testWidgets('should show encryption options', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(note: testNote));

      // Act
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Encrypt'), findsOneWidget);
    });

    testWidgets('should show encryption dialog', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(note: testNote));

      // Act
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Encrypt'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Encrypt Note'), findsOneWidget);
      expect(find.text('Enter a password to encrypt this note'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should encrypt note when password is provided', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(note: testNote));

      // Act
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Encrypt'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'password123',
      );
      await tester.tap(find.text('Encrypt'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNotesBloc.add(any(that: isA<EncryptNote>()))).called(1);
    });

    testWidgets('should show decryption dialog for encrypted notes', (WidgetTester tester) async {
      // Arrange
      final encryptedNote = testNote.copyWith(
        isEncrypted: true,
        password: 'password123',
      );
      await tester.pumpWidget(createWidgetUnderTest(note: encryptedNote));

      // Assert
      expect(find.text('Enter Password'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should attempt to decrypt note with password', (WidgetTester tester) async {
      // Arrange
      final encryptedNote = testNote.copyWith(
        isEncrypted: true,
        password: 'password123',
      );
      await tester.pumpWidget(createWidgetUnderTest(note: encryptedNote));

      // Act
      await tester.enterText(
        find.byType(TextField),
        'password123',
      );
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNotesBloc.add(any(that: isA<DecryptNote>()))).called(1);
    });

    testWidgets('should show error for wrong password', (WidgetTester tester) async {
      // Arrange
      final encryptedNote = testNote.copyWith(
        isEncrypted: true,
        password: 'password123',
        lockCounter: 1,
      );
      when(() => mockNotesBloc.state).thenReturn(NotesError(
        'Invalid password',
        notes: const [],
      ));
      await tester.pumpWidget(createWidgetUnderTest(note: encryptedNote));

      // Act
      await tester.enterText(
        find.byType(TextField),
        'wrongpassword',
      );
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Invalid password'), findsOneWidget);
      verify(() => mockNotesBloc.add(any(that: isA<UpdateLockCounter>()))).called(1);
    });

    testWidgets('should discard changes when back button is pressed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(note: testNote));

      // Act
      await tester.enterText(
        find.byType(TextFormField).first,
        'Changed Title',
      );
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Discard changes?'), findsOneWidget);
      expect(find.text('Your changes will be lost if you leave without saving.'), findsOneWidget);
      expect(find.text('Keep editing'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
    });

    testWidgets('should keep editing when discard is cancelled', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(note: testNote));

      // Act
      await tester.enterText(
        find.byType(TextFormField).first,
        'Changed Title',
      );
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Changed Title'), findsOneWidget);
    });

    testWidgets('should discard changes when confirmed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(note: testNote));

      // Act
      await tester.enterText(
        find.byType(TextFormField).first,
        'Changed Title',
      );
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      // Assert
      verifyNever(() => mockNotesBloc.add(any()));
    });
  });
} 