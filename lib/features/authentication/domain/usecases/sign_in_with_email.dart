import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailParams {
  final String email;
  final String password;

  const SignInWithEmailParams({
    required this.email,
    required this.password,
  });
}

class SignInWithEmail {
  final AuthRepository repository;

  const SignInWithEmail(this.repository);

  Future<User> call(SignInWithEmailParams params) async {
    if (params.email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }
    if (params.password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    return repository.signInWithEmailAndPassword(
      params.email,
      params.password,
    );
  }
} 