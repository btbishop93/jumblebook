class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
} 