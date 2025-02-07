import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jumblebook/widgets/authentication/user_context.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter binding initialized');
    
    // Configure system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light, // For iOS
      ),
    );

    // Ensure the status bar remains visible and prevent system UI changes
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
    print('Firebase app name: ${app.name}');
    print('Firebase options: ${app.options.projectId}');
  } catch (e, stackTrace) {
    print('Error initializing Firebase: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
  
  runApp(
    ChangeNotifierProvider<AuthService>(
      create: (BuildContext context) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jumblebook',
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(245, 148, 46, 1.0),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light, // For iOS
          ),
        ),
        textTheme: const TextTheme(
          titleMedium: TextStyle(fontSize: 18.0),
          labelLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(245, 148, 46, 1.0),
          elevation: 10,
        ),
        buttonBarTheme: ButtonBarThemeData(
          alignment: MainAxisAlignment.center,
          buttonHeight: Theme.of(context).buttonTheme.height * 1.5,
        ),
      ),
      home: const UserContext(),
    );
  }
}
