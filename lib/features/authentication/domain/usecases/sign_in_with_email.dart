import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import 'auth_params.dart';

class SignInWithEmail {
  final AuthRepository repository;

  const SignInWithEmail(this.repository);

  Future<User> call(EmailAuthParams params) async {
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
