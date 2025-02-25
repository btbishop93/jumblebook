import '../entities/form_data.dart';

class AuthValidator {
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
    FormData? formData,
  }) {
    if (value == null || (value.isEmpty && type != FormType.UNJUMBLE)) {
      return 'Enter a password.';
    }

    switch (type) {
      case FormType.REGISTER:
        if (value.length < 8)
          return 'Use 8 characters or more for your password.';
        return value != formData?.password ? 'Passwords do not match.' : null;
      case FormType.JUMBLE:
        return value.length < 8
            ? 'Use 8 characters or more for your password.'
            : null;
      case FormType.UNJUMBLE:
        if (formData == null) return 'Invalid form data';
        return value != formData.password
            ? 'Incorrect password. ${unjumbleAttemptMessage(formData)}'
            : null;
      default:
        return null;
    }
  }

  static String unjumbleAttemptMessage(FormData formData) {
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
