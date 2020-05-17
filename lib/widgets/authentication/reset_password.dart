import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jumblebook/models/user.dart';
import 'package:jumblebook/services/auth_service.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class PasswordReset extends StatefulWidget {
  @override
  _PasswordResetState createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _validate = false;
  String _email = "";
  String _emailErrorText;
  bool loading = false;

  FocusNode _emailFocusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onOnFocusNodeEvent);
  }

  _onOnFocusNodeEvent() {
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
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
                child: Container(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
