import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jumblebook/features/notes/domain/entities/note.dart';
import 'package:jumblebook/features/notes/data/models/note_model.dart';
import 'package:jumblebook/features/notes/presentation/widgets/jumble_prompt.dart';

void main() {
  late StreamController<bool> validationController;
  final testNote = Note(
    id: '1',
    title: 'Test Note',
    content: 'Test Content',
    date: DateTime.now(),
    password: NoteModel.hashPassword('correctpass'), // Store hashed password
    isEncrypted: true,
  );

  setUp(() {
    validationController = StreamController<bool>.broadcast();
  });

  tearDown(() {
    validationController.close();
  });

  Widget createWidgetUnderTest({
    bool isJumbling = true,
    PasswordForm? formData,
    required Function(PasswordForm) onFormUpdate,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          key: GlobalKey<FormState>(),
          autovalidateMode: AutovalidateMode.always,
          child: PasswordInputForm(
            isJumbling: isJumbling,
            onFormUpdate: onFormUpdate,
            triggerValidation: validationController.stream,
            formData: formData,
            note: testNote,
          ),
        ),
      ),
    );
  }

  group('PasswordInputForm', () {
    testWidgets('should render password input field', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        onFormUpdate: (_) {},
      ));

      // Assert
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('should validate empty password', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        onFormUpdate: (_) {},
      ));

      // Act
      validationController.add(true);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enter a password.'), findsOneWidget);
    });

    testWidgets('should validate password length when jumbling', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        isJumbling: true,
        onFormUpdate: (_) {},
      ));

      // Act
      await tester.enterText(
        find.byType(TextFormField),
        '123',
      );
      validationController.add(true);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Use 8 characters or more for your password.'), findsOneWidget);
    });

    testWidgets('should call onFormUpdate with valid password when jumbling', (WidgetTester tester) async {
      // Arrange
      PasswordForm? updatedForm;
      await tester.pumpWidget(createWidgetUnderTest(
        isJumbling: true,
        onFormUpdate: (form) => updatedForm = form,
      ));

      // Act
      await tester.enterText(
        find.byType(TextFormField),
        'password123',
      );
      validationController.add(true);
      await tester.pumpAndSettle();

      // Assert
      expect(updatedForm, isNotNull);
      expect(updatedForm?.password, equals('password123'));
    });

    testWidgets('should accept correct password when unjumbling', (WidgetTester tester) async {
      // Arrange
      PasswordForm? updatedForm;
      await tester.pumpWidget(createWidgetUnderTest(
        isJumbling: false,
        formData: PasswordForm(
          password: testNote.password,
          lockCounter: 0,
        ),
        onFormUpdate: (form) => updatedForm = form,
      ));

      // Act
      await tester.enterText(
        find.byType(TextFormField),
        'correctpass',  // Enter the original unhashed password
      );
      validationController.add(true);
      await tester.pumpAndSettle();

      // Assert
      expect(updatedForm, isNotNull);
      expect(updatedForm?.success, isTrue);
    });

    testWidgets('should show first warning on incorrect password', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        isJumbling: false,
        formData: PasswordForm(
          password: testNote.password,
          lockCounter: 0,
        ),
        onFormUpdate: (_) {},
      ));

      // Act
      await tester.enterText(
        find.byType(TextFormField),
        'wrongpass',
      );
      validationController.add(true);
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('Warning! This note will be locked after 2 more failed attempts.'),
        findsOneWidget,
      );
    });

    testWidgets('should show second warning on second failed attempt', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        isJumbling: false,
        formData: PasswordForm(
          password: testNote.password,
          lockCounter: 1,
        ),
        onFormUpdate: (_) {},
      ));

      // Act
      await tester.enterText(
        find.byType(TextFormField),
        'wrongpass',
      );
      validationController.add(true);
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('Warning! This note will be locked after 1 more failed attempt.'),
        findsOneWidget,
      );
    });

    testWidgets('should show locked message on third failed attempt', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        isJumbling: false,
        formData: PasswordForm(
          password: testNote.password,
          lockCounter: 2,
        ),
        onFormUpdate: (_) {},
      ));

      // Act
      await tester.enterText(
        find.byType(TextFormField),
        'wrongpass',
      );
      validationController.add(true);
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('This note is now locked and can only be unlocked via TouchID or FaceID.'),
        findsOneWidget,
      );
    });

    testWidgets('should show helper text when jumbling', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        isJumbling: true,
        onFormUpdate: (_) {},
      ));

      // Assert
      expect(
        find.text('Use 8 or more characters with a mix of letters, numbers & symbols.'),
        findsOneWidget,
      );
    });

    testWidgets('should clear error text on input change', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        onFormUpdate: (_) {},
      ));

      // Show error
      validationController.add(true);
      await tester.pumpAndSettle();
      expect(find.text('Enter a password.'), findsOneWidget);

      // Act - enter text
      await tester.enterText(find.byType(TextFormField), 'password123');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enter a password.'), findsNothing);
    });
  });
} 