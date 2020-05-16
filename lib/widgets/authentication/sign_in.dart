import 'package:flutter/material.dart';
import 'package:jumblebook/services/auth_service.dart';
import 'package:jumblebook/widgets/shared/CustomTextFormField.dart';
import 'package:loading_overlay/loading_overlay.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//        appBar: AppBar(
//          title: Image.asset(
//            'assets/images/title.png',
//            fit: BoxFit.contain,
//            height: 36,
//          ),
//          backgroundColor: Colors.transparent,
//          elevation: 0,
//        ),
        body: LoadingOverlay(
      color: Colors.grey,
      isLoading: loading,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 0.5, color: Colors.grey),
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/title.png',
                  fit: BoxFit.contain,
                  height: 36,
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
                  ),
                  validator: (val) => val.isEmpty ? 'Please enter an email' : null,
                  onChanged: (val) {
                    setState(() {
                      email = val;
                    });
                  },
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
                  ),
                  validator: (val) => val.isEmpty ? 'Please enter a password' : null,
                  onChanged: (val) {
                    setState(() {
                      password = val;
                    });
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                ),
                SizedBox(
                  height: 45,
                ),
                RaisedButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text("Log in"),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      setState(() {
                        loading = true;
                      });
                      dynamic result = await _authService.signInWithEmailAndPassword(email, password);
                      if (result == null) {
                        // handle error results properly, i.e. incorrect email/password, too many login attempts, etc.
                        setState(() {
                          loading = false;
                          error = "Please enter the correct email and/or password.";
                        });
                      }
                    }
                  },
                ),
                Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  child: Text(
                    'I dont have an account',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  onPressed: widget.toggleView,
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
