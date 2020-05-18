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

  static String validatePassword(String value, FormType type) {
    if (value.length == 0) {
      return 'Enter a password.';
    }
    if (type == FormType.REGISTER) {
      return value.length < 8 ? 'Use 8 characters or more for your password.' : null;
    }
    return null;
  }
}
