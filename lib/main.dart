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
import 'features/authentication/domain/usecases/usecases.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event.dart';
import 'features/authentication/presentation/pages/authenticate_page.dart';

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

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ThemeBloc()),
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: authRepository,
              signInWithEmail: SignInWithEmail(authRepository),
              signUpWithEmail: SignUpWithEmail(authRepository),
              signInWithGoogle: SignInWithGoogle(authRepository),
              signInWithApple: SignInWithApple(authRepository),
              signInAnonymously: SignInAnonymously(authRepository),
              signOut: SignOut(authRepository),
              resetPassword: ResetPassword(authRepository),
            )..add(CheckAuthStatus()), // Check auth status when app starts
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('Error initializing app: $e');
    print('Stack trace: $stackTrace');
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
