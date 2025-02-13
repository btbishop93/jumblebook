import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isAnonymous,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, isAnonymous];
} 