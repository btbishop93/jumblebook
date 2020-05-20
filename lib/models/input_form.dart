class InputForm {
  String email;
  String password;
  int lockCounter;
  bool loading;
  bool success;

  InputForm({this.email, this.password, this.lockCounter, this.loading, this.success});
}
