import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import 'auth_params.dart';

class SignUpWithEmail {
  final AuthRepository repository;

  const SignUpWithEmail(this.repository);

  Future<User> call(EmailAuthParams params) async {
    if (params.email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }
    if (params.password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }
    if (params.password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }

    return repository.signUpWithEmailAndPassword(
      params.email,
      params.password,
    );
  }
}
