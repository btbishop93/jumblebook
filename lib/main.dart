import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/bloc/theme_state.dart';
import 'features/authentication/data/datasources/firebase_auth_datasource.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/usecases/usecases.dart' as auth_usecases;
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event.dart';
import 'features/authentication/presentation/pages/authenticate_page.dart';
import 'features/notes/data/datasources/notes_remote_datasource.dart';
import 'features/notes/data/repositories/notes_repository_impl.dart';
import 'features/notes/domain/usecases/usecases.dart' as notes_usecases;
import 'features/notes/presentation/bloc/notes_bloc.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Configure system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize auth dependencies
    final authDataSource = FirebaseAuthDataSource();
    final authRepository = AuthRepositoryImpl(authDataSource);

    // Initialize notes dependencies
    final notesDataSource = FirebaseNotesDataSource();
    final notesRepository = NotesRepositoryImpl(notesDataSource);

    // Initialize notes use cases
    final getNotes = notes_usecases.GetNotes(notesRepository);
    final saveNote = notes_usecases.SaveNote(notesRepository);
    final deleteNote = notes_usecases.DeleteNote(notesRepository);
    final jumbleNote = notes_usecases.JumbleNote(notesRepository);
    final unjumbleNote = notes_usecases.UnjumbleNote(notesRepository);
    final updateLockCounter = notes_usecases.UpdateLockCounter(notesRepository);

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ThemeBloc()),
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: authRepository,
              signInWithEmail: auth_usecases.SignInWithEmail(authRepository),
              signUpWithEmail: auth_usecases.SignUpWithEmail(authRepository),
              signInWithGoogle: auth_usecases.SignInWithGoogle(authRepository),
              signInWithApple: auth_usecases.SignInWithApple(authRepository),
              signInAnonymously:
                  auth_usecases.SignInAnonymously(authRepository),
              signOut: auth_usecases.SignOut(authRepository),
              resetPassword: auth_usecases.ResetPassword(authRepository),
            )..add(CheckAuthStatus()), // Check auth status when app starts
          ),
          BlocProvider(
            create: (context) => NotesBloc(
              getNotes: getNotes,
              saveNote: saveNote,
              deleteNote: deleteNote,
              jumbleNote: jumbleNote,
              unjumbleNote: unjumbleNote,
              updateLockCounter: updateLockCounter,
              notesRepository: notesRepository,
            ),
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Error initializing app: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'Jumblebook',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.themeMode,
          home: const AuthenticatePage(),
        );
      },
    );
  }
}
