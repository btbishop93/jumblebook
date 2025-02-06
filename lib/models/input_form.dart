class InputForm {
  String email;
  String password;
  int lockCounter;
  bool loading;
  bool success;

  InputForm({
    this.email = '',
    this.password = '',
    this.lockCounter = 0,
    this.loading = false,
    this.success = false,
  });
}

enum FormType {
  LOGIN,
  REGISTER,
  FORGOT_PASSWORD,
  PASSWORD_RESET,
  ENCRYPT,
  DECRYPT,
}
