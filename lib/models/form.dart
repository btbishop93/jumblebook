class CustomInputForm {
  String email;
  String password;
  int lockCounter;
  bool loading;
  bool success;

  CustomInputForm({this.email, this.password, this.lockCounter, this.loading, this.success});
}
