import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import 'auth_params.dart';

class SignInWithGoogle {
  final AuthRepository repository;

  const SignInWithGoogle(this.repository);

  Future<User> call(NoParams params) async {
    return repository.signInWithGoogle();
  }
}
