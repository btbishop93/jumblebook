import 'package:flutter/material.dart';
import 'package:jumblebook/models/auth_errors.dart';
import 'package:jumblebook/services/auth_service.dart';
import 'package:jumblebook/widgets/shared/CustomTextFormField.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _validate = false;
  String _email = "";
  String _password = "";
  String _emailErrorText;
  String _passwordErrorText;
  String error = "";
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
      dynamic result = await Provider.of<AuthService>(context, listen: false).registerWithEmailAndPassword(_email, _password);
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

  applyErrorCodeResponse(String code) {
    AuthError reason = AuthError.values.firstWhere((e) => e.toString() == 'AuthError.' + code, orElse: () => null);
    setState(() {
      switch (reason) {
        case AuthError.ERROR_EMAIL_ALREADY_IN_USE:
          {
            _emailErrorText = "This email address is already registered.";
            FocusScope.of(context).requestFocus(_emailFocusNode);
          }
          break;
        default:
          {
            _passwordErrorText = "We cannot create your account at this time. Try again later.";
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          }
          break;
      }
    });
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter a valid email';
    else
      return null;
  }

  String validatePassword(String value) {
    if (value.length < 8)
      return value.length == 0 ? 'Enter a password' : 'Use 8 characters or more for your password';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: LoadingOverlay(
        isLoading: loading,
        color: Colors.grey,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 0.5, color: Colors.grey),
            ),
          ),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  autovalidate: _validate,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/title.png',
                        fit: BoxFit.contain,
                        height: 54,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      TextFormField(
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
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
                          helperTextStr: 'Use 8 or more characters with a mix of letters, numbers & symbols',
                          floatingLabel: _passwordFocusNode.hasFocus ? FloatingLabelBehavior.auto : FloatingLabelBehavior.never,
                        ),
                        validator: validatePassword,
                        onSaved: (val) => _password = val,
                        onChanged: (val) => setState(() {
                          _passwordErrorText = null;
                        }),
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
                          child: Text("Sign up"),
                          onPressed: validateCredentials,
                        ),
                      ),
                      FlatButton(
                        textColor: Theme.of(context).primaryColor,
                        child: Text(
                          'Log in',
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        onPressed: widget.toggleView,
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
