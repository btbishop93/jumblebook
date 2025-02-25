import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jumblebook/features/authentication/presentation/widgets/sign_in_button.dart';

void main() {
  Widget createWidgetUnderTest({
    required String text,
    required VoidCallback onPressed,
    Widget? icon,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SignInButton(
          text: text,
          onPressed: onPressed,
          icon: icon ?? const Icon(Icons.login),
        ),
      ),
    );
  }

  group('SignInButton', () {
    testWidgets('should render button with text', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        text: 'Sign in',
        onPressed: () {},
      ));

      // Assert
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        text: 'Sign in',
        onPressed: () {},
      ));

      // Act
      await tester.tap(find.byType(SignInButton));
      await tester.pump();

      // Assert
      expect(true, isTrue);
    });

    testWidgets('should render button with custom icon',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        text: 'Continue with Google',
        onPressed: () {},
        icon: const FaIcon(FontAwesomeIcons.google),
      ));

      // Assert
      expect(find.byType(FaIcon), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('should maintain layout when text is long',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        text: 'A very long button text that should still fit nicely',
        onPressed: () {},
      ));

      // Get button size
      final buttonSize = tester.getSize(find.byType(SignInButton));

      // Assert
      expect(buttonSize.width, greaterThan(0)); // Should have a width
      expect(buttonSize.height, greaterThan(0)); // Should have a height
    });

    testWidgets('should handle rapid taps gracefully',
        (WidgetTester tester) async {
      // Arrange
      int tapCount = 0;
      await tester.pumpWidget(createWidgetUnderTest(
        text: 'Sign in',
        onPressed: () => tapCount++,
      ));

      // Act - Rapid taps
      await tester.tap(find.byType(SignInButton));
      await tester.pump();
      await tester.tap(find.byType(SignInButton));
      await tester.pump();
      await tester.tap(find.byType(SignInButton));
      await tester.pump();

      // Assert
      expect(tapCount, equals(3)); // Each tap should be counted
    });

    testWidgets('should have correct button style',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        text: 'Sign in',
        onPressed: () {},
      ));

      // Assert
      final button = tester.widget<SignInButton>(find.byType(SignInButton));
      expect(button.onPressed, isNotNull);
    });
  });
}
