import '../repositories/auth_repository.dart';
import 'auth_params.dart';

class SignOut {
  final AuthRepository repository;

  const SignOut(this.repository);

  Future<void> call(NoParams params) async {
    return repository.signOut();
  }
}
