import 'package:jumblebook/models/input_form.dart';

class Validator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter an email address.';
    }

    final pattern = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    );
    
    return pattern.hasMatch(value) ? null : 'Enter a valid email.';
  }

  static String? validatePassword({
    required String? value,
    required FormType type,
    InputForm? formData,
  }) {
    if (value == null || (value.isEmpty && type != FormType.DECRYPT)) {
      return 'Enter a password.';
    }

    switch (type) {
      case FormType.REGISTER:
        if (value.length < 8) return 'Use 8 characters or more for your password.';
        return value != formData?.password ? 'Passwords do not match.' : null;
      case FormType.ENCRYPT:
        return value.length < 8 ? 'Use 8 characters or more for your password.' : null;
      case FormType.DECRYPT:
        if (formData == null) return 'Invalid form data';
        return value != formData.password 
            ? 'Incorrect password. ${decryptAttemptMessage(formData)}'
            : null;
      default:
        return null;
    }
  }

  static String decryptAttemptMessage(InputForm formData) {
    switch (formData.lockCounter) {
      case 0:
        return 'Warning! This note will be locked after 2 more failed attempts.';
      case 1:
        return 'Warning! This note will be locked after 1 more failed attempt.';
      default:
        return 'This note is now locked and can only be unlocked via TouchID or FaceID.';
    }
  }
}
