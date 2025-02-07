import 'package:flutter/material.dart';

class CustomInputDecoration {
  static InputDecoration formStyle({
    required BuildContext context,
    Widget? icon,
    String labelTextStr = "",
    String hintTextStr = "",
    String? errorTextStr,
    String? helperTextStr,
    Color noFocusBorderColor = Colors.black26,
    FloatingLabelBehavior floatingLabel = FloatingLabelBehavior.auto,
  }) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      floatingLabelBehavior: floatingLabel,
      labelText: labelTextStr,
      labelStyle: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 14,
      ),
      hintText: hintTextStr,
      helperText: helperTextStr,
      helperMaxLines: 3,
      helperStyle: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 10,
      ),
      prefixIcon: icon != null 
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: IconTheme(
                data: IconThemeData(
                  color: Colors.grey.shade600,
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
      fillColor: Colors.grey.shade50,
      errorMaxLines: 3,
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      errorStyle: const TextStyle(
        color: Colors.red,
        fontSize: 12,
      ),
      errorText: errorTextStr,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
