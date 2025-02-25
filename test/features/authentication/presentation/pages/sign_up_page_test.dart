import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_event.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_state.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_data.dart';
import 'package:jumblebook/features/authentication/presentation/pages/sign_up_page.dart';
import 'package:jumblebook/features/authentication/presentation/widgets/auth_form.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockNavigatorObserver = MockNavigatorObserver();
    registerFallbackValue(SignUpWithEmailRequested(
      email: 'test@example.com',
      password: 'password123',
    ));
    registerFallbackValue(SignInAnonymouslyRequested());

    // Default state
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ScaffoldMessenger(
        child: Scaffold(
          body: BlocProvider<AuthBloc>(
            create: (context) => mockAuthBloc,
            child: SignUpPage(toggleView: () {}),
          ),
        ),
      ),
      navigatorObservers: [mockNavigatorObserver],
    );
  }

  group('SignUpPage', () {
    testWidgets('should render sign up form', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.byType(TextFormField),
          findsNWidgets(3)); // Email, password, and confirm password fields
      expect(
          find.text(
              'Use 8 or more characters with a mix of letters, numbers & symbols.'),
          findsOneWidget);
    });

    testWidgets('should show error message when sign up fails',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - Simulate failed sign up
      mockAuthBloc.emit(AuthError(AuthData(), 'Email already in use'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Email already in use'), findsOneWidget);
    });

    testWidgets('should trigger sign up when form is submitted',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Fill in form
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'password123',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );
      await tester.pump();

      // Find and tap the submit button
      final form = tester.widget<AuthForm>(find.byType(AuthForm));
      form.onSubmit('test@example.com', 'password123');
      await tester.pump();

      // Assert
      verify(() => mockAuthBloc.add(SignUpWithEmailRequested(
            email: 'test@example.com',
            password: 'password123',
          ))).called(1);
    });

    testWidgets('should show loading state during authentication',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthLoading(AuthData()));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert - Find Skeletonizer within the widget tree
      final skeletonizerFinder = find.byWidgetPredicate(
        (widget) => widget is Skeletonizer && widget.enabled == true,
      );
      expect(skeletonizerFinder, findsOneWidget);
    });

    testWidgets('should trigger anonymous sign in when guest button is pressed',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.binding.setSurfaceSize(const Size(800, 800));
      await tester.pump();

      // Scroll to make the button visible
      await tester.dragFrom(
        tester.getCenter(find.byType(SingleChildScrollView)),
        const Offset(0, -500),
      );
      await tester.pump();

      // Act
      await tester.tap(find.text('Sign in as Guest'));
      await tester.pump();

      // Assert
      verify(() => mockAuthBloc.add(SignInAnonymouslyRequested())).called(1);

      // Clean up
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should validate email field', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - Submit with invalid email
      await tester.enterText(
        find.byType(TextFormField).first,
        'invalid-email',
      );
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Assert
      expect(
        find.descendant(
          of: find.byType(TextFormField).first,
          matching: find.text('Enter a valid email.'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should validate password field', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - Submit with empty password
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Assert
      expect(
        find.descendant(
          of: find.byType(TextFormField).at(1),
          matching: find.text('Enter a password.'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should validate password length', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - Submit with short password
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '12345',
      );
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Assert
      expect(
        find.descendant(
          of: find.byType(TextFormField).at(1),
          matching: find.text('Use 8 characters or more for your password.'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should validate matching passwords',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - Submit with non-matching passwords
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'password123',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password456',
      );
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Assert
      expect(
        find.descendant(
          of: find.byType(TextFormField).last,
          matching: find.text('Passwords do not match.'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should toggle to sign in page when toggle button is pressed',
        (WidgetTester tester) async {
      // Arrange
      bool toggleCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldMessenger(
            child: Scaffold(
              body: BlocProvider<AuthBloc>(
                create: (context) => mockAuthBloc,
                child: SignUpPage(toggleView: () => toggleCalled = true),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      // Assert
      expect(toggleCalled, isTrue);
    });
  });
}
