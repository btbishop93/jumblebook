import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:jumblebook/models/input_form.dart';
import 'package:jumblebook/services/auth_service.dart';
import 'package:jumblebook/widgets/shared/custom_input_form.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import 'reset_password.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool loading = false;

  void _updateFormData(InputForm form) {
    setState(() {
      this.loading = form.loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: LoadingOverlay(
        color: Colors.grey,
        isLoading: loading,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 0.5, color: Colors.grey),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(30),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/title.png',
                        fit: BoxFit.contain,
                        height: 54,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      CustomInputForm(
                        formType: FormType.LOGIN,
                        emitFormDataFunction: _updateFormData,
                      ),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            FlatButton(
                              textColor: Theme.of(context).primaryColor,
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                              ),
                              onPressed: () async {
                                await resetPasswordPrompt(context, null);
                              },
                            ),
                            SizedBox(
                              height: 20,
                              width: 5,
                              child: VerticalDivider(color: Colors.black54),
                            ),
                            FlatButton(
                              textColor: Theme.of(context).primaryColor,
                              child: Text(
                                'Create an account',
                                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                              ),
                              onPressed: widget.toggleView,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(children: <Widget>[
                        Expanded(
                            child: Divider(
                          color: Colors.black54,
                        )),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "OR",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                          color: Colors.black54,
                        )),
                      ]),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 220,
                          child: RaisedButton(
                            color: Theme.of(context).primaryColor,
                            textColor: Colors.white,
                            child: Text(
                              'Sign in as Guest',
                              style: TextStyle(fontSize: 14),
                            ),
                            onPressed: () async {
                              setState(() {
                                this.loading = true;
                              });
                              dynamic result = await Provider.of<AuthService>(context, listen: false).signInAsGuest();
                              setState(() {
                                this.loading = false;
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
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
                            Buttons.AppleDark,
                            onPressed: () async {
                              setState(() {
                                this.loading = true;
                              });
                              dynamic result = await Provider.of<AuthService>(context, listen: false).signInWithApple();
                              setState(() {
                                this.loading = false;
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 36,
                          child: SignInButton(
                            Buttons.GoogleDark,
                            onPressed: () async {
                              setState(() {
                                this.loading = true;
                              });
                              dynamic result = await Provider.of<AuthService>(context, listen: false).signInWithGoogle();
                              setState(() {
                                this.loading = false;
                              });
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
    ));
  }
}
