enum FormType {
  LOGIN,
  REGISTER,
  FORGOT_PASSWORD,
  PASSWORD_RESET,
  JUMBLE,
  UNJUMBLE,
}

class FormData {
  String email;
  String password;
  bool loading;
  bool success;
  int lockCounter;

  FormData({
    this.email = '',
    this.password = '',
    this.loading = false,
    this.success = false,
    this.lockCounter = 0,
  });

  FormData copyWith({
    String? email,
    String? password,
    bool? loading,
    bool? success,
    int? lockCounter,
  }) {
    return FormData(
      email: email ?? this.email,
      password: password ?? this.password,
      loading: loading ?? this.loading,
      success: success ?? this.success,
      lockCounter: lockCounter ?? this.lockCounter,
    );
  }
}
