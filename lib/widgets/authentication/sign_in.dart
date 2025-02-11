import 'package:flutter/material.dart';
import 'package:jumblebook/models/input_form.dart';
import 'package:jumblebook/services/auth_service.dart';
import 'package:jumblebook/widgets/shared/custom_input_form.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../shared/sign_in_button.dart';

class SignIn extends StatefulWidget {
  final VoidCallback toggleView;

  const SignIn({required this.toggleView, super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool loading = false;

  void _updateFormData(InputForm form) {
    setState(() {
      loading = form.loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Skeletonizer(
          enabled: loading,
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
                  // Social Sign In Buttons
                  SignInButton(
                    text: 'Sign in with Google',
                    icon: SvgPicture.asset(
                      'assets/images/social/g_logo.svg',
                      width: 20,
                      height: 20,
                    ),
                    onPressed: () async {
                      setState(() => loading = true);
                      await Provider.of<AuthService>(context, listen: false)
                          .signInWithGoogle();
                      if (mounted) setState(() => loading = false);
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
                    onPressed: () async {
                      setState(() => loading = true);
                      await Provider.of<AuthService>(context, listen: false)
                          .signInWithApple();
                      if (mounted) setState(() => loading = false);
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
                  CustomInputForm(
                    formType: FormType.LOGIN,
                    emitFormDataFunction: _updateFormData,
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
                        onPressed: widget.toggleView,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
