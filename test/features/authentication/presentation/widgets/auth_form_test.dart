import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jumblebook/features/authentication/domain/entities/form_data.dart';
import 'package:jumblebook/features/authentication/presentation/widgets/auth_form.dart';

void main() {
  Widget createWidgetUnderTest({
    required FormType formType,
    required Function(String email, String password) onSubmit,
    String? submitButtonText,
    FormData? formData,
    Stream<bool>? triggerValidation,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AuthForm(
          formType: formType,
          onSubmit: onSubmit,
          submitButtonText: submitButtonText ?? 'Submit',
          formData: formData,
          triggerValidation: triggerValidation,
        ),
      ),
    );
  }

  group('AuthForm', () {
    testWidgets('should render sign in form fields', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        formType: FormType.LOGIN,
        onSubmit: (email, password) {
        },
      ));

      // Assert
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should render sign up form fields', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        formType: FormType.REGISTER,
        onSubmit: (_, __) {},
      ));

      // Assert
      expect(find.byType(TextFormField), findsNWidgets(3)); // Email, password, and confirm password
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('should show validation message for invalid email',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        formType: FormType.LOGIN,
        onSubmit: (_, __) {},
      ));

      // Act
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.pump();

      // Submit form to trigger validation
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Assert
      expect(find.text('Enter a valid email.'), findsOneWidget);
    });

    testWidgets('should show validation message for short password',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        formType: FormType.REGISTER,
        onSubmit: (_, __) {},
      ));

      // Act
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.pump();

      // Submit form to trigger validation
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Assert
      expect(find.text('Use 8 characters or more for your password.'),
          findsOneWidget);
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        formType: FormType.LOGIN,
        onSubmit: (_, __) {},
      ));

      // Get password field
      final passwordField = find.byType(TextField).at(1);

      // Assert initial state (password should be obscured)
      expect(tester.widget<TextField>(passwordField).obscureText, isTrue);
    });

    testWidgets('should clear form after successful submission',
        (WidgetTester tester) async {
      // Arrange
      bool submitted = false;
      await tester.pumpWidget(createWidgetUnderTest(
        formType: FormType.LOGIN,
        onSubmit: (email, password) {
          submitted = true;
        },
      ));

      // Act - Enter valid credentials
      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pump();

      // Submit form
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Assert
      expect(submitted, isTrue);
    });

    testWidgets('should show helper text for password in register mode',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        formType: FormType.REGISTER,
        onSubmit: (_, __) {},
      ));

      // Assert
      expect(
          find.text(
              'Use 8 or more characters with a mix of letters, numbers & symbols.'),
          findsOneWidget);
    });

    testWidgets('should validate matching passwords in register mode',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        formType: FormType.REGISTER,
        onSubmit: (_, __) {},
      ));

      // Act - Enter non-matching passwords
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.enterText(find.byType(TextFormField).at(2), 'password456');
      await tester.pump();

      // Submit form to trigger validation
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Assert - Find the error message in the confirm password field
      expect(
        find.descendant(
          of: find.byType(TextFormField).at(2),
          matching: find.text('Passwords do not match.'),
        ),
        findsOneWidget,
      );
    });
  });
} 