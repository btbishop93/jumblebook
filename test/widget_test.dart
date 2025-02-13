// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jumblebook/core/theme/bloc/theme_bloc.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_state.dart';
import 'package:jumblebook/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/main.dart';

class MockAuthBloc extends Mock implements AuthBloc {
  @override
  Stream<AuthState> get stream => Stream.fromIterable([state]);

  @override
  AuthState get state => AuthInitial();

  @override
  Future<void> close() async {}
}

class MockNotesBloc extends Mock implements NotesBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockNotesBloc mockNotesBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockNotesBloc = MockNotesBloc();
  });

  testWidgets('App should render without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ThemeBloc()),
          BlocProvider<AuthBloc>(create: (context) => mockAuthBloc),
          BlocProvider<NotesBloc>(create: (context) => mockNotesBloc),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app renders without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
