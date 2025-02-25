import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import 'auth_params.dart';

class SignInWithApple {
  final AuthRepository repository;

  const SignInWithApple(this.repository);

  Future<User> call(NoParams params) async {
    return repository.signInWithApple();
  }
}
