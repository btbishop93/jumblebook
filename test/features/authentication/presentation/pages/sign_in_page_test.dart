import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_event.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_state.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_data.dart';
import 'package:jumblebook/features/authentication/presentation/pages/sign_in_page.dart';

class MockAuthBloc extends Mock implements AuthBloc {
  final _controller = StreamController<AuthState>.broadcast();

  @override
  Stream<AuthState> get stream => _controller.stream;

  @override
  Future<void> close() async {
    await _controller.close();
  }

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
    registerFallbackValue(SignInWithEmailRequested(
      email: 'test@example.com',
      password: 'password123',
    ));
    registerFallbackValue(SignInWithGoogleRequested());
    registerFallbackValue(SignInWithAppleRequested());

    // Default state
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ScaffoldMessenger(
        child: Scaffold(
          body: BlocProvider<AuthBloc>(
            create: (context) => mockAuthBloc,
            child: SignInPage(toggleView: () {}),
          ),
        ),
      ),
      navigatorObservers: [mockNavigatorObserver],
    );
  }

  group('SignInPage', () {
    testWidgets('should render sign in form', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
    });

    testWidgets('should show error message when sign in fails', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - Simulate failed sign in
      mockAuthBloc.emit(AuthError(AuthData(), 'Invalid credentials'));
      await tester.pump(); // Rebuild after state change
      await tester.pump(const Duration(milliseconds: 100)); // Wait for SnackBar animation

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.descendant(
        of: find.byType(SnackBar),
        matching: find.text('Invalid credentials'),
      ), findsOneWidget);
    });

    testWidgets('should trigger sign in when form is submitted', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - Fill in form
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      // Submit form
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      verify(() => mockAuthBloc.add(any(that: isA<SignInWithEmailRequested>()))).called(1);
    });

    testWidgets('should show loading indicator during authentication', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - Simulate loading state
      mockAuthBloc.emit(AuthLoading(AuthData()));
      await tester.pump(); // Rebuild after state change
      await tester.pump(const Duration(milliseconds: 100)); // Wait for animations

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should trigger Google sign in when Google button is pressed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Sign in with Google'));
      await tester.pump();

      // Assert
      verify(() => mockAuthBloc.add(SignInWithGoogleRequested())).called(1);
    });

    testWidgets('should trigger Apple sign in when Apple button is pressed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Sign in with Apple'));
      await tester.pump();

      // Assert
      verify(() => mockAuthBloc.add(SignInWithAppleRequested())).called(1);
    });

    testWidgets('should validate email field', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - Submit with invalid email
      await tester.enterText(
        find.byType(TextFormField).first,
        'invalid-email',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Enter a valid email.'), findsOneWidget);
    });

    testWidgets('should validate password field', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - Submit with empty password
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Enter a password.'), findsOneWidget);
    });

    testWidgets('should toggle to sign up page when toggle button is pressed', (WidgetTester tester) async {
      // Arrange
      bool toggleCalled = false;
      await tester.binding.setSurfaceSize(const Size(800, 1000)); // Set larger window size
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldMessenger(
            child: Scaffold(
              body: BlocProvider<AuthBloc>(
                create: (context) => mockAuthBloc,
                child: SignInPage(toggleView: () => toggleCalled = true),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Sign up'));
      await tester.pump();

      // Assert
      expect(toggleCalled, isTrue);

      // Clean up
      await tester.binding.setSurfaceSize(null);
    });
  });
} 