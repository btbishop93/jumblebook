import 'package:flutter/material.dart';
import 'package:jumblebook/constants/auth_error.dart';
import 'package:jumblebook/models/custom_input_decoration.dart';
import 'package:jumblebook/models/input_form.dart';
import 'package:jumblebook/services/auth_service.dart';
import 'package:jumblebook/utils/validators_util.dart';
import 'package:provider/provider.dart';

class CustomInputForm extends StatefulWidget {
  final FormType formType;

  // Create a function on parent to setState with updated formData to do xyz.
  final ValueChanged<InputForm> emitFormDataFunction;
  final InputForm? formData;
  final Stream<bool>? triggerValidation;

  const CustomInputForm({
    super.key,
    required this.formType,
    required this.emitFormDataFunction,
    this.formData,
    this.triggerValidation,
  });

  @override
  State<CustomInputForm> createState() => _CustomInputFormState();
}

class _CustomInputFormState extends State<CustomInputForm> {
  final _formKey = GlobalKey<FormState>();
  late InputForm _formData;
  bool _validate = false;
  String? _emailErrorText;
  String? _passwordErrorText;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _formData = widget.formData ?? InputForm();
    if (widget.triggerValidation != null) {
      widget.triggerValidation!.listen((bool value) {
        if (value) {
          validateCredentials();
        }
      });
    }
    _emailFocusNode.addListener(_onFocusNodeEvent);
    _passwordFocusNode.addListener(_onFocusNodeEvent);
    _confirmPasswordFocusNode.addListener(_onFocusNodeEvent);
    _passwordErrorText =
        widget.formType == FormType.DECRYPT && _formData.lockCounter > 0 
            ? Validator.decryptAttemptMessage(_formData) 
            : null;
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _onFocusNodeEvent() {
    setState(() {});
  }

  Future<void> validateCredentials() async {
    if (!mounted) return;
    
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      setState(() {
        _validate = true;
        _formData.loading = widget.formType == FormType.REGISTER || widget.formType == FormType.LOGIN;
        _formData.success = widget.formType == FormType.DECRYPT;
        widget.emitFormDataFunction(_formData);
      });

      dynamic result;
      switch (widget.formType) {
        case FormType.REGISTER:
          result = await Provider.of<AuthService>(context, listen: false)
              .registerWithEmailAndPassword(_formData.email, _formData.password);
          break;
        case FormType.LOGIN:
          result = await Provider.of<AuthService>(context, listen: false)
              .signInWithEmailAndPassword(_formData.email, _formData.password);
          break;
        case FormType.FORGOT_PASSWORD:
          result = await Provider.of<AuthService>(context, listen: false)
              .resetPassword(_formData.email);
          if (result == null) {
            if (mounted) {
              setState(() {
                _formData.loading = false;
                _formData.success = true;
                widget.emitFormDataFunction(_formData);
              });
            }
          }
          break;
        default:
          break;
      }

      if (result != null && mounted) {
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
        if (widget.formType == FormType.DECRYPT) {
          _formData.lockCounter++;
          widget.emitFormDataFunction(_formData);
        } else {
          _validate = true;
        }
      });
    }
  }

  void applyErrorCodeResponse(String code) {
    final reason = AuthError.values.firstWhere(
      (e) => e.toString() == 'AuthError.$code',
      orElse: () => AuthError.ERROR_UNKNOWN,
    );

    setState(() {
      switch (reason) {
        case AuthError.ERROR_EMAIL_ALREADY_IN_USE:
          _emailErrorText = 'This email address is already registered.';
          FocusScope.of(context).requestFocus(_emailFocusNode);
          break;
        case AuthError.ERROR_USER_NOT_FOUND:
          _emailErrorText = 'We could not find an account for that email address.';
          FocusScope.of(context).requestFocus(_emailFocusNode);
          break;
        default:
          switch (widget.formType) {
            case FormType.REGISTER:
              _emailErrorText = 'We cannot create your account at this time. Try again later.';
              FocusScope.of(context).requestFocus(_emailFocusNode);
              break;
            case FormType.LOGIN:
              _passwordErrorText = 'The email or password you entered is incorrect.';
              FocusScope.of(context).requestFocus(_passwordFocusNode);
              break;
            case FormType.FORGOT_PASSWORD:
              _passwordErrorText = 'We cannot reset your password at this time. Try again later.';
              FocusScope.of(context).requestFocus(_emailFocusNode);
              break;
            default:
              break;
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final submitButton = widget.formType == FormType.REGISTER ? 'Sign up' : 'Login';
    
    return Form(
      key: _formKey,
      autovalidateMode: _validate ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: widget.formType != FormType.LOGIN && widget.formType != FormType.REGISTER 
            ? MainAxisSize.min 
            : MainAxisSize.max,
        children: <Widget>[
          if (widget.formType != FormType.ENCRYPT && widget.formType != FormType.DECRYPT)
            TextFormField(
              focusNode: _emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              decoration: CustomInputDecoration.formStyle(
                context: context,
                icon: const Icon(Icons.email),
                labelTextStr: 'Email',
                floatingLabel: _emailFocusNode.hasFocus 
                    ? FloatingLabelBehavior.auto 
                    : FloatingLabelBehavior.never,
                errorTextStr: _emailErrorText,
              ),
              validator: Validator.validateEmail,
              onSaved: (val) => _formData.email = val ?? '',
              onChanged: (val) => setState(() {
                _emailErrorText = null;
              }),
              textInputAction: widget.formType != FormType.FORGOT_PASSWORD && 
                             widget.formType != FormType.PASSWORD_RESET
                  ? TextInputAction.next
                  : TextInputAction.send,
              onFieldSubmitted: (_) {
                if (widget.formType != FormType.FORGOT_PASSWORD && 
                    widget.formType != FormType.PASSWORD_RESET) {
                  FocusScope.of(context).nextFocus();
                } else {
                  validateCredentials();
                }
              },
            )
          else
            TextFormField(
              enabled: widget.formType == FormType.DECRYPT ? _formData.lockCounter < 3 : true,
              obscureText: true,
              focusNode: _passwordFocusNode,
              decoration: CustomInputDecoration.formStyle(
                context: context,
                icon: const Icon(Icons.lock),
                labelTextStr: 'Password',
                helperTextStr: widget.formType == FormType.REGISTER 
                    ? 'Use 8 or more characters with a mix of letters, numbers & symbols.' 
                    : null,
                floatingLabel: _passwordFocusNode.hasFocus 
                    ? FloatingLabelBehavior.auto 
                    : FloatingLabelBehavior.never,
                errorTextStr: _passwordErrorText,
                noFocusBorderColor: Colors.white,
              ),
              validator: (val) => widget.formType == FormType.ENCRYPT
                  ? Validator.validatePassword(value: val, type: FormType.ENCRYPT)
                  : Validator.validatePassword(value: val, type: widget.formType, formData: _formData),
              onSaved: (val) => _formData.password = val ?? '',
              onChanged: (val) => setState(() {
                if (widget.formType == FormType.ENCRYPT) _formData.password = val;
                _passwordErrorText = null;
              }),
              textInputAction: widget.formType == FormType.ENCRYPT 
                  ? TextInputAction.next 
                  : TextInputAction.done,
              onFieldSubmitted: (_) {
                if (widget.formType == FormType.ENCRYPT) {
                  FocusScope.of(context).nextFocus();
                } else {
                  validateCredentials();
                }
              },
            ),
          const SizedBox(height: 10),
          if (widget.formType != FormType.FORGOT_PASSWORD && 
              widget.formType != FormType.PASSWORD_RESET && 
              widget.formType != FormType.DECRYPT)
            TextFormField(
              obscureText: true,
              focusNode: widget.formType == FormType.ENCRYPT 
                  ? _confirmPasswordFocusNode 
                  : _passwordFocusNode,
              decoration: CustomInputDecoration.formStyle(
                context: context,
                icon: const Icon(Icons.lock),
                labelTextStr: widget.formType != FormType.ENCRYPT ? 'Password' : 'Confirm',
                helperTextStr: widget.formType == FormType.REGISTER 
                    ? 'Use 8 or more characters with a mix of letters, numbers & symbols.' 
                    : null,
                floatingLabel: _passwordFocusNode.hasFocus || _confirmPasswordFocusNode.hasFocus
                    ? FloatingLabelBehavior.auto
                    : FloatingLabelBehavior.never,
                errorTextStr: _passwordErrorText,
                noFocusBorderColor: widget.formType == FormType.ENCRYPT 
                    ? Colors.white 
                    : Colors.black26,
              ),
              validator: (val) => Validator.validatePassword(
                value: val,
                type: widget.formType,
                formData: _formData,
              ),
              onSaved: (val) => _formData.password = val ?? '',
              onChanged: (val) => setState(() {
                _passwordErrorText = null;
              }),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => validateCredentials(),
            ),
        ],
      ),
    );
  }
}
