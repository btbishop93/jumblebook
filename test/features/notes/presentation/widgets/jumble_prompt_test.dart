import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jumblebook/features/notes/domain/entities/note.dart';
import 'package:jumblebook/features/notes/presentation/widgets/jumble_prompt.dart';

void main() {
  late Note testNote;

  setUp(() {
    testNote = Note(
      id: 'test-note-id',
      title: 'Test Note',
      content: 'Test content',
      date: DateTime.now(),
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => jumblePrompt(context, 'Test Title', testNote),
            child: const Text('Show Dialog'),
          ),
        ),
      ),
    );
  }

  group('jumblePrompt', () {
    testWidgets('should render dialog with form fields', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should submit form with valid input', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter password
      await tester.enterText(
        find.byType(TextFormField),
        'password123',
      );
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should validate empty password', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Submit without password
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enter a password.'), findsOneWidget);
    });

    testWidgets('should close dialog when cancel is pressed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Press cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should show jumbled message for new note', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('Create a password. You will need your password or biometric authentication to Unjumble this note.'),
        findsOneWidget,
      );
    });

    testWidgets('should show unjumbling message for jumbled note', (WidgetTester tester) async {
      // Arrange
      testNote = testNote.copyWith(isEncrypted: true);
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('To unjumble this note, enter your password.'),
        findsOneWidget,
      );
    });

    testWidgets('should show helper text when jumbling', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('Use 8 or more characters with a mix of letters, numbers & symbols.'),
        findsOneWidget,
      );
    });
  });
} 