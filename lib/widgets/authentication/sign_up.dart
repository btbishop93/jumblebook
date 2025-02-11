import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jumblebook/models/input_form.dart';
import 'package:jumblebook/widgets/shared/custom_input_form.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../services/auth_service.dart';
import '../shared/sign_in_button.dart';

class SignUp extends StatefulWidget {
  final VoidCallback toggleView;

  const SignUp({required this.toggleView, super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
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
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Skeletonizer(
          enabled: loading,
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
                    children: <Widget>[
                      const SizedBox(height: 40),
                      // Logo
                      Image.asset(
                        'assets/images/title.png',
                        height: 54,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 48),
                      CustomInputForm(
                        formType: FormType.REGISTER,
                        emitFormDataFunction: _updateFormData,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Have an account? ',
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                          ),
                          TextButton(
                            onPressed: widget.toggleView,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                          Expanded(child: Divider(color: theme.dividerColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                            ),
                          ),
                          Expanded(child: Divider(color: theme.dividerColor)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SignInButton(
                        text: 'Sign in as Guest',
                        icon: Icon(
                          FontAwesomeIcons.userSecret,
                          size: 20,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        onPressed: () async {
                          setState(() => loading = true);
                          await Provider.of<AuthService>(context, listen: false)
                              .signInAsGuest();
                          if (mounted) setState(() => loading = false);
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
  }
}
