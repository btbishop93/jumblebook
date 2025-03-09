import '../repositories/auth_repository.dart';
import 'auth_params.dart';

class DeleteAccount {
  final AuthRepository repository;

  const DeleteAccount(this.repository);

  Future<void> call(NoParams params) async {
    return repository.deleteAccount();
  }
} 