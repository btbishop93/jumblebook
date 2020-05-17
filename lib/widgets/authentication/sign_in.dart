import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:jumblebook/models/auth_errors.dart';
import 'package:jumblebook/services/auth_service.dart';
import 'package:jumblebook/widgets/shared/CustomTextFormField.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  bool _validate = false;

  String _email = "";
  String _password = "";
  String _emailErrorText;
  String _passwordErrorText;
  bool loading = false;

  FocusNode _emailFocusNode = new FocusNode();
  FocusNode _passwordFocusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onOnFocusNodeEvent);
    _passwordFocusNode.addListener(_onOnFocusNodeEvent);
  }

  _onOnFocusNodeEvent() {
    setState(() {});
  }

  validateCredentials() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _validate = true;
        loading = true;
      });
      dynamic result = await Provider.of<AuthService>(context, listen: false).signInWithEmailAndPassword(_email, _password);
      if (result != null) {
        setState(() {
          loading = false;
        });
        if (result is String) {
          applyErrorCodeResponse(result);
        }
      }
    } else {
      setState(() {
        _validate = true;
      });
    }
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter a valid email.';
    else
      return null;
  }

  String validatePassword(String value) {
    return value.length == 0 ? 'Enter a password.' : null;
  }

  applyErrorCodeResponse(String code) {
    AuthError reason = AuthError.values.firstWhere((e) => e.toString() == 'AuthError.' + code, orElse: () => null);
    setState(() {
      switch (reason) {
        case AuthError.ERROR_USER_NOT_FOUND:
          {
            _emailErrorText = "We could not find an account for that email address.";
            FocusScope.of(context).requestFocus(_emailFocusNode);
          }
          break;
        default:
          {
            _passwordErrorText = "The email or password you entered is incorrect.";
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          }
          break;
      }
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
                child: Form(
                  key: _formKey,
                  autovalidate: _validate,
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
                          height: 20,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          focusNode: _emailFocusNode,
                          decoration: CustomInputDecoration.formStyle(
                            context: context,
                            icon: Icon(Icons.email),
                            labelTextStr: 'Email',
                            floatingLabel: _emailFocusNode.hasFocus ? FloatingLabelBehavior.auto : FloatingLabelBehavior.never,
                            errorTextStr: _emailErrorText,
                          ),
                          validator: validateEmail,
                          onSaved: (val) => _email = val,
                          onChanged: (val) => setState(() {
                            _emailErrorText = null;
                          }),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          obscureText: true,
                          focusNode: _passwordFocusNode,
                          decoration: CustomInputDecoration.formStyle(
                            context: context,
                            icon: Icon(Icons.lock),
                            labelTextStr: 'Password',
                            floatingLabel: _passwordFocusNode.hasFocus ? FloatingLabelBehavior.auto : FloatingLabelBehavior.never,
                            errorTextStr: _passwordErrorText,
                          ),
                          onChanged: (val) => setState(() {
                            _passwordErrorText = null;
                          }),
                          validator: validatePassword,
                          onSaved: (val) => _password = val,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => validateCredentials(),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.maxFinite,
                          child: RaisedButton(
                            color: Theme.of(context).primaryColor,
                            textColor: Colors.white,
                            child: Text("Log in"),
                            onPressed: validateCredentials,
                          ),
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
                                onPressed: () => {},
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
                          child: Text(
                            'Login using social media',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 35,
                            child: SignInButton(
                              Buttons.GoogleDark,
                              onPressed: () {},
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 35,
                            child: SignInButton(
                              Buttons.AppleDark,
                              onPressed: () {},
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 35,
                            child: SignInButton(
                              Buttons.Facebook,
                              onPressed: () {},
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
      ),
    ));
  }
}
