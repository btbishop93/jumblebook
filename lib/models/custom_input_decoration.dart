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
      contentPadding: const EdgeInsets.all(1.0),
      floatingLabelBehavior: floatingLabel,
      labelText: labelTextStr,
      hintText: hintTextStr,
      helperText: helperTextStr,
      helperMaxLines: 3,
      helperStyle: const TextStyle(color: Colors.black),
      prefixIcon: icon,
      fillColor: Colors.white,
      errorMaxLines: 3,
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      errorStyle: const TextStyle(
        color: Colors.red,
      ),
      errorText: errorTextStr,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: noFocusBorderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
    );
  }
}
