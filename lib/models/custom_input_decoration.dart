import 'package:flutter/material.dart';

class CustomInputDecoration {
  static InputDecoration formStyle({
    required BuildContext context,
    Widget? icon,
    String labelTextStr = "",
    String hintTextStr = "",
    String? errorTextStr,
    String? helperTextStr,
    Color? noFocusBorderColor,
    FloatingLabelBehavior floatingLabel = FloatingLabelBehavior.auto,
  }) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;
    
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      floatingLabelBehavior: floatingLabel,
      labelText: labelTextStr,
      labelStyle: inputTheme.labelStyle,
      hintText: hintTextStr,
      helperText: helperTextStr,
      helperMaxLines: 3,
      helperStyle: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
      prefixIcon: icon != null 
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: IconTheme(
                data: IconThemeData(
                  color: inputTheme.prefixIconColor,
                  size: 20,
                ),
                child: icon,
              ),
            )
          : null,
      prefixIconConstraints: const BoxConstraints(
        minWidth: 48,
        minHeight: 48,
      ),
      fillColor: inputTheme.fillColor,
      errorMaxLines: 3,
      focusedErrorBorder: inputTheme.focusedErrorBorder,
      errorStyle: TextStyle(
        color: theme.colorScheme.error,
        fontSize: 12,
      ),
      errorText: errorTextStr,
      filled: inputTheme.filled,
      enabledBorder: inputTheme.enabledBorder,
      focusedBorder: inputTheme.focusedBorder,
      errorBorder: inputTheme.errorBorder,
    );
  }
}
