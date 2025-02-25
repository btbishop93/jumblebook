import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import 'auth_params.dart';

class SignInAnonymously {
  final AuthRepository repository;

  const SignInAnonymously(this.repository);

  Future<User> call(NoParams params) async {
    return repository.signInAnonymously();
  }
}
