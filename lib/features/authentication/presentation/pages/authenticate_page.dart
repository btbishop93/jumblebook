import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';
import '../../../notes/presentation/pages/notes_page.dart';

class AuthenticatePage extends StatefulWidget {
  const AuthenticatePage({super.key});

  @override
  State<AuthenticatePage> createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage> {
  bool showSignIn = true;

  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated && state.data.user != null) {
          return NotesPage(currentUser: state.data.user!);
        }

        return showSignIn
            ? SignInPage(toggleView: toggleView)
            : SignUpPage(toggleView: toggleView);
      },
    );
  }
}
