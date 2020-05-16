import 'package:flutter/material.dart';
import 'package:jumblebook/models/user.dart';
import 'package:jumblebook/services/auth_service.dart';
import 'package:jumblebook/widgets/authentication/user_context.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: 'Jumblebook',
        theme: ThemeData(
          primaryColor: Color.fromRGBO(245, 148, 46, 1.0),
          textTheme: TextTheme(
            subtitle1: TextStyle(fontSize: 18.0),
            button: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color.fromRGBO(245, 148, 46, 1.0), // Background color (orange in my case).
            elevation: 10,
          ),
          buttonBarTheme: ButtonBarThemeData(
            alignment: MainAxisAlignment.center,
            buttonHeight: Theme.of(context).buttonTheme.height * 1.5,
          ),
        ),
        home: UserContext(),
      ),
    );
  }
}
