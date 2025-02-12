import 'package:flutter/material.dart';

class CustomInputDecoration {
  static InputDecoration formStyle({
    required BuildContext context,
    required Widget icon,
    required String labelTextStr,
    String? helperTextStr,
    String? errorTextStr,
    FloatingLabelBehavior? floatingLabel,
    Color? noFocusBorderColor,
  }) {
    final theme = Theme.of(context);
    
    return InputDecoration(
      prefixIcon: icon,
      labelText: labelTextStr,
      helperText: helperTextStr,
      helperMaxLines: 2,
      helperStyle: TextStyle(
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
      ),
      errorText: errorTextStr,
      floatingLabelBehavior: floatingLabel ?? FloatingLabelBehavior.auto,
      labelStyle: TextStyle(
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: noFocusBorderColor ?? theme.dividerColor,
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
    );
  }
} 