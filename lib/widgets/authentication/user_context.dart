import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:jumblebook/features/authentication/presentation/bloc/auth_state.dart';
import 'package:jumblebook/widgets/authentication/authenticate.dart';
import 'package:jumblebook/widgets/shared/loading_indicator.dart';
import '../../features/notes/presentation/pages/notes_page.dart';

class UserContext extends StatelessWidget {
  const UserContext({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const LoadingCircle();
        }

        if (state is Authenticated && state.data.user != null) {
          return NotesPage(currentUser: state.data.user!);
        }

        return const Authenticate();
      },
    );
  }
}

