class User {
  final String uid;
  final String? email;
  final bool isAnonymous;

  const User({
    required this.uid,
    this.email,
    required this.isAnonymous,
  });
}
