import 'package:flutter/material.dart';

class CustomInputDecoration {
  static InputDecoration formStyle({
    BuildContext context,
    Icon icon,
    String labelTextStr = "",
    String hintTextStr = "",
    String errorTextStr,
    String helperTextStr,
    FloatingLabelBehavior floatingLabel = FloatingLabelBehavior.auto,
  }) {
    return InputDecoration(
      contentPadding: EdgeInsets.all(1.0),
      floatingLabelBehavior: floatingLabel,
      labelText: labelTextStr,
      hintText: hintTextStr,
      helperText: helperTextStr,
      helperMaxLines: 3,
      helperStyle: TextStyle(color: Colors.black),
      prefixIcon: icon,
      fillColor: Colors.white,
      errorMaxLines: 3,
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      errorStyle: TextStyle(
        color: Colors.red, // or any other color
      ),
      errorText: errorTextStr,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black26, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
    );
  }
}
