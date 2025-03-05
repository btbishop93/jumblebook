import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../domain/entities/form_data.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_form.dart';
import '../widgets/sign_in_button.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({required this.toggleView, super.key});

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
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Logo
                    Image.asset(
                      'assets/images/title.png',
                      height: 54,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 48),
                    if (state is AuthLoading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      // Social Sign In Buttons
                      SignInButton(
                        text: 'Sign in with Google',
                        icon: SvgPicture.asset(
                          'assets/images/social/g_logo.svg',
                          width: 20,
                          height: 20,
                        ),
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(SignInWithGoogleRequested());
                        },
                      ),
                      const SizedBox(height: 16),
                      SignInButton(
                        text: 'Sign in with Apple',
                        icon: Icon(
                          FontAwesomeIcons.apple,
                          size: 24,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(SignInWithAppleRequested());
                        },
                      ),
                      const SizedBox(height: 32),
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: theme.dividerColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          Expanded(child: Divider(color: theme.dividerColor)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Email Sign In Form
                      AuthForm(
                        formType: FormType.login,
                        onSubmit: (email, password) {
                          context.read<AuthBloc>().add(
                                SignInWithEmailRequested(
                                  email: email,
                                  password: password,
                                ),
                              );
                        },
                        submitButtonText: 'Sign In',
                      ),
                      const SizedBox(height: 32),
                      // No Account Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No account? ',
                            style: theme.textTheme.bodySmall,
                          ),
                          TextButton(
                            onPressed: toggleView,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
