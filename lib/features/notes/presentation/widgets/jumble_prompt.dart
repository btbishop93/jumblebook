import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/note.dart';

class Prompt {
  String password;
  int lockCounter;

  Prompt(this.password, this.lockCounter);
}

class PasswordForm {
  String password;
  bool success;
  int lockCounter;

  PasswordForm({
    this.password = '',
    this.success = false,
    this.lockCounter = 0,
  });
}

Future<Prompt> jumblePrompt(BuildContext context, String title, Note note) async {
  final controller = StreamController<bool>();
  final isEncrypted = note.isEncrypted;
  
  final result = await showDialog<Prompt>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final result = Prompt("", note.lockCounter);

          void onConfirmAction() async {
            if (note.lockCounter >= 3) {
              Navigator.of(context).pop(result);
            } else {
              controller.add(true);
            }
          }

          void updateFormData(PasswordForm form) {
            setState(() {
              result.password = form.password;
              if (isEncrypted) {
                if (form.success == true) {
                  controller.close();
                  Navigator.of(context).pop(result);
                } else {
                  result.lockCounter = form.lockCounter;
                  result.password = "";
                }
              } else {
                controller.close();
                Navigator.of(context).pop(result);
              }
            });
          }

          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            title: Center(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  !isEncrypted
                      ? const Text(
                          'Create a password. You will need your password or biometric authentication to Unjumble this note.',
                          style: TextStyle(fontSize: 12),
                        )
                      : const Text(
                          'To unjumble this note, enter your password.',
                          style: TextStyle(fontSize: 12),
                        ),
                  const SizedBox(height: 24),
                  !isEncrypted
                      ? PasswordInputForm(
                          isEncrypting: true,
                          onFormUpdate: updateFormData,
                          triggerValidation: controller.stream,
                        )
                      : PasswordInputForm(
                          isEncrypting: false,
                          onFormUpdate: updateFormData,
                          formData: PasswordForm(
                            lockCounter: note.lockCounter,
                            password: note.password,
                          ),
                          triggerValidation: controller.stream,
                        ),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        result.password = "";
                        Navigator.of(context).pop(result);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirmAction,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Send',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
  
  return result ?? Prompt("", note.lockCounter);
}

class PasswordInputForm extends StatefulWidget {
  final bool isEncrypting;
  final Function(PasswordForm) onFormUpdate;
  final Stream<bool> triggerValidation;
  final PasswordForm? formData;

  const PasswordInputForm({
    super.key,
    required this.isEncrypting,
    required this.onFormUpdate,
    required this.triggerValidation,
    this.formData,
  });

  @override
  State<PasswordInputForm> createState() => _PasswordInputFormState();
}

class _PasswordInputFormState extends State<PasswordInputForm> {
  final _formKey = GlobalKey<FormState>();
  late PasswordForm _formData;
  bool _validate = false;
  String? _passwordErrorText;

  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _formData = widget.formData ?? PasswordForm();
    widget.triggerValidation.listen((bool value) {
      if (value) {
        _validatePassword();
      }
    });
    _passwordFocusNode.addListener(_onFocusNodeEvent);
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onFocusNodeEvent() {
    setState(() {});
  }

  void _validatePassword() {
    if (!mounted) return;

    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      widget.onFormUpdate(_formData);
    } else {
      setState(() {
        _validate = true;
      });
    }
  }

  String? _validatePasswordField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a password.';
    }

    if (widget.isEncrypting) {
      if (value.length < 8) {
        return 'Use 8 characters or more for your password.';
      }
      return null;
    } else {
      if (widget.formData == null) return 'Invalid form data';
      if (value != widget.formData!.password) {
        switch (_formData.lockCounter) {
          case 0:
            _formData.lockCounter = 1;
            return 'Warning! This note will be locked after 2 more failed attempts.';
          case 1:
            _formData.lockCounter = 2;
            return 'Warning! This note will be locked after 1 more failed attempt.';
          default:
            _formData.lockCounter = 3;
            return 'This note is now locked and can only be unlocked via TouchID or FaceID.';
        }
      }
      _formData.success = true;
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Form(
      key: _formKey,
      autovalidateMode: _validate ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            focusNode: _passwordFocusNode,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock),
              labelText: 'Password',
              helperText: widget.isEncrypting
                  ? 'Use 8 or more characters with a mix of letters, numbers & symbols.'
                  : null,
              helperMaxLines: 2,
              helperStyle: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
              errorText: _passwordErrorText,
              floatingLabelBehavior: _passwordFocusNode.hasFocus
                  ? FloatingLabelBehavior.auto
                  : FloatingLabelBehavior.never,
              labelStyle: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.dividerColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.primaryColor,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            validator: _validatePasswordField,
            onSaved: (val) => _formData.password = val ?? '',
            onChanged: (val) => setState(() {
              _passwordErrorText = null;
              _formData.password = val;
            }),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _validatePassword(),
          ),
        ],
      ),
    );
  }
} 