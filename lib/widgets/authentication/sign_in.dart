import 'package:flutter/material.dart';
import 'package:jumblebook/models/input_form.dart';
import 'package:jumblebook/services/auth_service.dart';
import 'package:jumblebook/widgets/shared/custom_input_form.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:provider/provider.dart';

import 'reset_password.dart';

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
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Skeletonizer(
          enabled: loading,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 0.5, color: Colors.grey.shade400),
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/title.png',
                        fit: BoxFit.contain,
                        height: 54,
                      ),
                      const SizedBox(height: 25),
                      CustomInputForm(
                        formType: FormType.LOGIN,
                        emitFormDataFunction: _updateFormData,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Flexible(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  ),
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                                  ),
                                  onPressed: () async {
                                    await resetPasswordPrompt(context, null);
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 20,
                                width: 5,
                                child: VerticalDivider(color: Colors.grey.shade600),
                              ),
                              Flexible(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  ),
                                  child: const Text(
                                    'Create an account',
                                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                                  ),
                                  onPressed: widget.toggleView,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Divider(color: Colors.grey.shade600),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "OR",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 220,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Sign in as Guest',
                              style: TextStyle(fontSize: 14),
                            ),
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              await Provider.of<AuthService>(context, listen: false).signInAsGuest();
                              if (mounted) {
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Login using social media',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 36,
                          child: SignInButton(
                            Buttons.appleDark,
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              await Provider.of<AuthService>(context, listen: false).signInWithApple();
                              if (mounted) {
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 36,
                          child: SignInButton(
                            Buttons.googleDark,
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              await Provider.of<AuthService>(context, listen: false).signInWithGoogle();
                              if (mounted) {
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                          ),
                        ),
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
