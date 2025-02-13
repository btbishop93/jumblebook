import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jumblebook/features/notes/presentation/widgets/jumble_prompt.dart';

void main() {
  late StreamController<bool> validationController;

  setUp(() {
    validationController = StreamController<bool>.broadcast();
  });

  tearDown(() {
    validationController.close();
  });

  Widget createWidgetUnderTest({
    bool isEncrypting = true,
    PasswordForm? formData,
    required Function(PasswordForm) onFormUpdate,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          key: GlobalKey<FormState>(),
          autovalidateMode: AutovalidateMode.always,
          child: PasswordInputForm(
            isEncrypting: isEncrypting,
            onFormUpdate: onFormUpdate,
            triggerValidation: validationController.stream,
            formData: formData,
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

    testWidgets('should validate password length when encrypting', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        isEncrypting: true,
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

    testWidgets('should call onFormUpdate with valid password when encrypting', (WidgetTester tester) async {
      // Arrange
      PasswordForm? updatedForm;
      await tester.pumpWidget(createWidgetUnderTest(
        isEncrypting: true,
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

    testWidgets('should show warning on first failed attempt when decrypting', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        isEncrypting: false,
        formData: PasswordForm(
          password: 'correctpass',
          lockCounter: 0,
        ),
        onFormUpdate: (_) {},
      ));

      // Act
      await tester.enterText(
        find.byType(TextFormField),
        'wrongpass',
      );
      await tester.pump();

      // Assert
      final textFormField = tester.widget<TextFormField>(find.byType(TextFormField));
      final validator = textFormField.validator;
      final error = validator?.call('wrongpass');
      expect(error, equals('Warning! This note will be locked after 2 more failed attempts.'));
    });

    testWidgets('should show final warning on second failed attempt', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        isEncrypting: false,
        formData: PasswordForm(
          password: 'correctpass',
          lockCounter: 1,
        ),
        onFormUpdate: (_) {},
      ));

      // Act
      await tester.enterText(
        find.byType(TextFormField),
        'wrongpass',
      );
      await tester.pump();

      // Assert
      final textFormField = tester.widget<TextFormField>(find.byType(TextFormField));
      final validator = textFormField.validator;
      final error = validator?.call('wrongpass');
      expect(error, equals('Warning! This note will be locked after 1 more failed attempt.'));
    });

    testWidgets('should lock note after third failed attempt', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        isEncrypting: false,
        formData: PasswordForm(
          password: 'correctpass',
          lockCounter: 2,
        ),
        onFormUpdate: (_) {},
      ));

      // Act
      await tester.enterText(
        find.byType(TextFormField),
        'wrongpass',
      );
      await tester.pump();

      // Assert
      final textFormField = tester.widget<TextFormField>(find.byType(TextFormField));
      final validator = textFormField.validator;
      final error = validator?.call('wrongpass');
      expect(error, equals('This note is now locked and can only be unlocked via TouchID or FaceID.'));
    });

    testWidgets('should show helper text when encrypting', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        isEncrypting: true,
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