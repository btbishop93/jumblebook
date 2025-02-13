class EmailAuthParams {
  final String email;
  final String password;

  const EmailAuthParams({
    required this.email,
    required this.password,
  });
}

class EmailOnlyParams {
  final String email;

  const EmailOnlyParams({required this.email});
}

// Empty params for use cases that don't need parameters
class NoParams {
  const NoParams();
} 