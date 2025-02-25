import 'package:flutter/material.dart';
import '../../domain/entities/form_data.dart';
import '../../domain/validators/auth_validator.dart';
import '../pages/reset_password_page.dart';
import 'custom_input_decoration.dart';

class AuthForm extends StatefulWidget {
  final FormType formType;
  final Function(String email, String password) onSubmit;
  final String submitButtonText;
  final FormData? formData;
  final Stream<bool>? triggerValidation;

  const AuthForm({
    super.key,
    required this.formType,
    required this.onSubmit,
    required this.submitButtonText,
    this.formData,
    this.triggerValidation,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  late FormData _formData;
  bool _validate = false;
  String? _emailErrorText;
  String? _passwordErrorText;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _formData = widget.formData ?? FormData();
    if (widget.triggerValidation != null) {
      widget.triggerValidation!.listen((bool value) {
        if (value) {
          _validateCredentials();
        }
      });
    }
    _emailFocusNode.addListener(_onFocusNodeEvent);
    _passwordFocusNode.addListener(_onFocusNodeEvent);
    _confirmPasswordFocusNode.addListener(_onFocusNodeEvent);
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

  void _validateCredentials() {
    if (!mounted) return;

    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      widget.onSubmit(_formData.email, _formData.password);
    } else {
      setState(() {
        _validate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      autovalidateMode:
          _validate ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            focusNode: _emailFocusNode,
            autofillHints: const [AutofillHints.email],
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
            validator: AuthValidator.validateEmail,
            onSaved: (val) => _formData.email = val ?? '',
            onChanged: (val) => setState(() {
              _emailErrorText = null;
              _formData.email = val;
            }),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            focusNode: _passwordFocusNode,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
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
            ),
            validator: (val) => AuthValidator.validatePassword(
              value: val,
              type: widget.formType,
              formData: _formData,
            ),
            onSaved: (val) => _formData.password = val ?? '',
            onChanged: (val) => setState(() {
              _passwordErrorText = null;
            }),
            textInputAction: widget.formType == FormType.REGISTER
                ? TextInputAction.next
                : TextInputAction.done,
            onFieldSubmitted: (_) {
              if (widget.formType == FormType.REGISTER) {
                FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
              } else {
                _validateCredentials();
              }
            },
          ),
          if (widget.formType == FormType.LOGIN) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Save the current email
                  _formKey.currentState?.save();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResetPasswordPage(
                        email: _formData.email,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
          if (widget.formType == FormType.REGISTER) ...[
            const SizedBox(height: 16),
            TextFormField(
              focusNode: _confirmPasswordFocusNode,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: CustomInputDecoration.formStyle(
                context: context,
                icon: const Icon(Icons.lock),
                labelTextStr: 'Confirm Password',
                floatingLabel: _confirmPasswordFocusNode.hasFocus
                    ? FloatingLabelBehavior.auto
                    : FloatingLabelBehavior.never,
                errorTextStr: _passwordErrorText,
              ),
              validator: (val) => AuthValidator.validatePassword(
                value: val,
                type: widget.formType,
                formData: _formData,
              ),
              onSaved: (val) => _formData.password = val ?? '',
              onChanged: (val) => setState(() {
                _passwordErrorText = null;
              }),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _validateCredentials(),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _validateCredentials,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.submitButtonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
