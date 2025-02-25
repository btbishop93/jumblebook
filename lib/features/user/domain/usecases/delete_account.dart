import '../repositories/user_repository.dart';

class DeleteAccount {
  final UserRepository repository;

  const DeleteAccount(this.repository);

  Future<void> call(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    return repository.deleteAccount(userId);
  }
}
