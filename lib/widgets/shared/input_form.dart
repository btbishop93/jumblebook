import 'package:flutter/material.dart';
import 'package:jumblebook/models/auth_errors.dart';
import 'package:jumblebook/models/form.dart';
import 'package:jumblebook/models/note.dart';
import 'package:jumblebook/services/auth_service.dart';
import 'package:jumblebook/widgets/shared/validators_util.dart';
import 'package:provider/provider.dart';

import 'CustomTextFormField.dart';

enum FormType { REGISTER, LOGIN, ENCRYPT, DECRYPT, PASSWORD_RESET, FORGOT_PASSWORD }

class InputForm extends StatefulWidget {
  final FormType formType;

  // Create a function on parent to setState with updated formData to do xyz.
  final ValueChanged<CustomInputForm> emitFormDataFunction;
  final CustomInputForm formData;
  Stream<bool> triggerValidation;
  final Note note;

  InputForm({@required this.formType, this.emitFormDataFunction, this.formData, this.triggerValidation, this.note});

  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  final _formKey = GlobalKey<FormState>();
  CustomInputForm _formData;
  bool _validate = false;
  String _emailErrorText;
  String _passwordErrorText;

  FocusNode _emailFocusNode = new FocusNode();
  FocusNode _passwordFocusNode = new FocusNode();
  FocusNode _confirmPasswordFocusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    _formData = widget.formData != null ? widget.formData : CustomInputForm();
    if (widget.triggerValidation != null) {
      widget.triggerValidation.listen((bool) {
        if (bool == true) {
          validateCredentials();
        }
      });
    }
    _emailFocusNode.addListener(_onOnFocusNodeEvent);
    _passwordFocusNode.addListener(_onOnFocusNodeEvent);
    _confirmPasswordFocusNode.addListener(_onOnFocusNodeEvent);
  }

  _onOnFocusNodeEvent() {
    setState(() {});
  }

  validateCredentials() async {
    FocusScope.of(context).unfocus();
    dynamic result;
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _validate = true;
        _formData.loading = widget.formType == FormType.REGISTER || widget.formType == FormType.LOGIN;
        widget.emitFormDataFunction(_formData);
      });
      switch (widget.formType) {
        case FormType.REGISTER:
          {
            result =
                await Provider.of<AuthService>(context, listen: false).registerWithEmailAndPassword(_formData.email, _formData.password);
          }
          break;
        case FormType.LOGIN:
          {
            result = await Provider.of<AuthService>(context, listen: false).signInWithEmailAndPassword(_formData.email, _formData.password);
          }
          break;
        case FormType.FORGOT_PASSWORD:
          {
            result = await Provider.of<AuthService>(context, listen: false).resetPassword(_formData.email);
            if (result == null) {
              setState(() {
                _formData.loading = false;
                _formData.success = true;
                widget.emitFormDataFunction(_formData);
              });
            }
          }
          break;
        default:
          {}
      }
      if (result != null) {
        setState(() {
          _formData.loading = false;
          widget.emitFormDataFunction(_formData);
        });
        if (result is String) {
          applyErrorCodeResponse(result);
        }
      }
    } else {
      setState(() {
        _validate = true;
        if (widget.formType == FormType.DECRYPT) {
          widget.formData.password = "";
          widget.formData.lockCounter++;
          _getWrongAttemptMessage();
        }
      });
    }
  }

  void _getWrongAttemptMessage() {
    setState(() {
      if (widget.formData.lockCounter == 1) {
        _passwordErrorText = 'Warning! This note will be locked after 2 more failed attempts.';
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      }
      if (widget.formData.lockCounter == 2) {
        _passwordErrorText = 'Warning! This note will be locked after 1 more failed attempt.';
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      } else {
        _passwordErrorText = 'This note is now locked and can only be unlocked via TouchID or FaceID.';
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      }
    });
  }

  applyErrorCodeResponse(String code) {
    AuthError reason = AuthError.values.firstWhere((e) => e.toString() == 'AuthError.' + code, orElse: () => null);
    setState(() {
      switch (reason) {
        case AuthError.ERROR_EMAIL_ALREADY_IN_USE:
          {
            _emailErrorText = 'This email address is already registered.';
            FocusScope.of(context).requestFocus(_emailFocusNode);
          }
          break;
        case AuthError.ERROR_USER_NOT_FOUND:
          {
            _emailErrorText = 'We could not find an account for that email address.';
            FocusScope.of(context).requestFocus(_emailFocusNode);
          }
          break;
        default:
          {
            switch (widget.formType) {
              case FormType.REGISTER:
                {
                  _emailErrorText = 'We cannot create your account at this time. Try again later.';
                  FocusScope.of(context).requestFocus(_emailFocusNode);
                }
                break;
              case FormType.LOGIN:
                {
                  _passwordErrorText = 'The email or password you entered is incorrect.';
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                }
                break;
              case FormType.FORGOT_PASSWORD:
                {
                  _passwordErrorText = 'We cannot reset your password at this time. Try again later.';
                  FocusScope.of(context).requestFocus(_emailFocusNode);
                }
                break;
              default:
                {}
            }
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String _submitButton = widget.formType == FormType.REGISTER ? 'Sign up' : 'Login';
    return Form(
      key: _formKey,
      autovalidate: _validate,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // EMAIL INPUT, NOT FOR ENCRYPT/DECRYPT
          widget.formType != FormType.ENCRYPT && widget.formType != FormType.DECRYPT
              ? TextFormField(
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  decoration: CustomInputDecoration.formStyle(
                    context: context,
                    icon: Icon(Icons.email),
                    labelTextStr: 'Email',
                    floatingLabel: _emailFocusNode.hasFocus ? FloatingLabelBehavior.auto : FloatingLabelBehavior.never,
                    errorTextStr: _emailErrorText,
                  ),
                  validator: Validator.validateEmail,
                  onSaved: (val) => _formData.email = val,
                  onChanged: (val) => setState(() {
                    _emailErrorText = null;
                  }),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                )
              : TextFormField(
                  enabled: widget.formType == FormType.DECRYPT ? widget.formData.lockCounter < 3 : true,
                  obscureText: true,
                  focusNode: _passwordFocusNode,
                  decoration: CustomInputDecoration.formStyle(
                    context: context,
                    icon: Icon(Icons.lock),
                    labelTextStr: 'Password',
                    helperTextStr:
                        widget.formType == FormType.REGISTER ? 'Use 8 or more characters with a mix of letters, numbers & symbols.' : null,
                    floatingLabel: _passwordFocusNode.hasFocus ? FloatingLabelBehavior.auto : FloatingLabelBehavior.never,
                    errorTextStr: _passwordErrorText,
                    noFocusBorderColor: Colors.white,
                  ),
                  validator: (val) => Validator.validatePassword(val, widget.formType),
                  onSaved: (val) => _formData.password = val,
                  onChanged: (val) => setState(() {
                    _passwordErrorText = null;
                  }),
                  textInputAction: widget.formType != FormType.ENCRYPT ? TextInputAction.next : TextInputAction.done,
                  onFieldSubmitted: (_) => widget.formType != FormType.ENCRYPT ? FocusScope.of(context).nextFocus() : validateCredentials(),
                ),
          SizedBox(
            height: 10,
          ),
          // Password INPUT, not for FORGOT_PASSWORD or PASSWORD_RESET forms
          widget.formType != FormType.FORGOT_PASSWORD && widget.formType != FormType.PASSWORD_RESET && widget.formType != FormType.DECRYPT
              ? TextFormField(
                  obscureText: true,
                  focusNode: widget.formType == FormType.ENCRYPT ? _confirmPasswordFocusNode : _passwordFocusNode,
                  decoration: CustomInputDecoration.formStyle(
                    context: context,
                    icon: Icon(Icons.lock),
                    labelTextStr: widget.formType != FormType.ENCRYPT ? 'Password' : 'Confirm',
                    helperTextStr:
                        widget.formType == FormType.REGISTER ? 'Use 8 or more characters with a mix of letters, numbers & symbols.' : null,
                    floatingLabel: _passwordFocusNode.hasFocus || _confirmPasswordFocusNode.hasFocus
                        ? FloatingLabelBehavior.auto
                        : FloatingLabelBehavior.never,
                    errorTextStr: _passwordErrorText,
                    noFocusBorderColor: widget.formType == FormType.ENCRYPT ? Colors.white : null,
                  ),
                  validator: (val) => widget.formType != FormType.ENCRYPT
                      ? Validator.validatePassword(val, widget.formType)
                      : widget.formData.password == val,
                  onSaved: (val) => _formData.password = val,
                  onChanged: (val) => setState(() {
                    _passwordErrorText = null;
                  }),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => validateCredentials(),
                )
              : Container(),
          widget.formType == FormType.REGISTER || widget.formType == FormType.LOGIN
              ? SizedBox(
                  height: 20,
                )
              : Container(),
          widget.formType == FormType.REGISTER || widget.formType == FormType.LOGIN
              ? SizedBox(
                  width: double.maxFinite,
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(_submitButton),
                    onPressed: validateCredentials,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
