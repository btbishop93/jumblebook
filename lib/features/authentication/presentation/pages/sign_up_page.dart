import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../domain/entities/form_data.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_form.dart';
import '../widgets/sign_in_button.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({required this.toggleView, super.key});

  final VoidCallback toggleView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.data.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Skeletonizer(
              enabled: state is AuthLoading,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 0.5, color: theme.dividerColor),
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          // Logo
                          Image.asset(
                            'assets/images/title.png',
                            height: 54,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 48),
                          // Email Sign Up Form
                          AuthForm(
                            formType: FormType.REGISTER,
                            onSubmit: (email, password) {
                              context.read<AuthBloc>().add(
                                    SignUpWithEmailRequested(
                                      email: email,
                                      password: password,
                                    ),
                                  );
                            },
                            submitButtonText: 'Sign Up',
                          ),
                          const SizedBox(height: 32),
                          // Have Account Text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Have an account? ',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(fontSize: 14),
                              ),
                              TextButton(
                                onPressed: toggleView,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Sign in',
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Divider
                          Row(
                            children: [
                              Expanded(
                                  child: Divider(color: theme.dividerColor)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'or',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(fontSize: 14),
                                ),
                              ),
                              Expanded(
                                  child: Divider(color: theme.dividerColor)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Anonymous Sign In Button
                          SignInButton(
                            text: 'Sign in as Guest',
                            icon: Icon(
                              FontAwesomeIcons.userSecret,
                              size: 20,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                            onPressed: () {
                              context
                                  .read<AuthBloc>()
                                  .add(SignInAnonymouslyRequested());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
