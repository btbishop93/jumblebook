import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jumblebook/models/auth_errors.dart';
import 'package:jumblebook/models/user.dart';
import 'package:jumblebook/services/auth_service.dart';
import 'package:jumblebook/widgets/shared/CustomTextFormField.dart';
import 'package:provider/provider.dart';

Future<String> resetPasswordPrompt(BuildContext context, User user) async {
  final _formKey = GlobalKey<FormState>();
  String _title = user != null ? 'Are you sure?' : 'Forgot password?';
  bool _validate = false;
  String _email = "";
  String _emailErrorText;

  FocusNode _emailFocusNode = FocusNode();

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter a valid email';
    else
      return null;
  }

  applyErrorCodeResponse(String code) {
    AuthError reason = AuthError.values.firstWhere((e) => e.toString() == 'AuthError.' + code, orElse: () => null);
    switch (reason) {
      case AuthError.ERROR_USER_NOT_FOUND:
        {
          _emailErrorText = "We could not find an account for that email address.";
          FocusScope.of(context).requestFocus(_emailFocusNode);
        }
        break;
      default:
        {
          _emailErrorText = "We could not reset your password at this time.";
          FocusScope.of(context).unfocus();
        }
        break;
    }
  }

  return showDialog<String>(
    context: context,
    barrierDismissible: false, // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return AlertDialog(
        buttonPadding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        )),
        title: Center(child: Text(_title)),
        content: Form(
          key: _formKey,
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              user == null
                  ? TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: CustomInputDecoration.formStyle(
                        context: context,
                        icon: Icon(Icons.email),
                        labelTextStr: 'Email',
                        noFocusBorderColor: Colors.white,
                        errorTextStr: _emailErrorText,
                      ),
                      validator: validateEmail,
                      onSaved: (val) => _email = val,
                      onChanged: (val) {
                        _emailErrorText = null;
                      },
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    )
                  : Column(children: <Widget>[
                      Text(
                        'An email with password reset instructions will be sent to',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${user.email}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ])
            ],
          ),
        ),
        actions: <Widget>[
          Container(
            width: double.maxFinite,
            height: Theme.of(context).buttonTheme.height * 1.5,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: OutlineButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop('Cancel');
                    },
                  ),
                ),
                Expanded(
                  child: OutlineButton(
                    child: Text('Ok'),
                    onPressed: () async {
                      if (user == null) {
                        // User is not logged in and providing an email
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          // TODO: send password reset, if success close, if not display errorText
                          var result = await Provider.of<AuthService>(context, listen: false).resetPassword(_email);
                          Navigator.of(context).pop('Okay');
                        } else {
                          // TODO: handle validators
                          _validate = true;
                        }
                      } else {
                        // User is logged in
                        var result = await Provider.of<AuthService>(context, listen: false).resetPassword(user.email);
                        // TODO: send password reset, if success close, if not display errorText
                        Navigator.of(context).pop('Okay');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
