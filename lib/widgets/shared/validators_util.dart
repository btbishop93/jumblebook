import 'package:flutter/cupertino.dart';
import 'package:jumblebook/models/form.dart';
import 'package:jumblebook/widgets/shared/input_form.dart';

class Validator {
  static String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter a valid email.';
    else
      return null;
  }

  static String validatePassword({@required String value, FormType type, CustomInputForm formData}) {
    if (value.length == 0 && type != FormType.DECRYPT) {
      return 'Enter a password.';
    }
    if (type == FormType.REGISTER) {
      return value.length < 8 ? 'Use 8 characters or more for your password.' : null;
    }
    if (type == FormType.ENCRYPT) {
      return value != formData.password ? 'Passwords do not match.' : null;
    }
    if (type == FormType.DECRYPT) {
      return value != formData.password ? 'Incorrect password. ' + decryptAttemptMessage(formData) : null;
    }
    return null;
  }

  static decryptAttemptMessage(CustomInputForm formData) {
    if (formData.lockCounter == 0) {
      return 'Warning! This note will be locked after 2 more failed attempts.';
    }
    if (formData.lockCounter == 1) {
      return 'Warning! This note will be locked after 1 more failed attempt.';
    } else {
      return 'This note is now locked and can only be unlocked via TouchID or FaceID.';
    }
  }
}
