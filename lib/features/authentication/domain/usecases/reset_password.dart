import '../repositories/auth_repository.dart';
import 'auth_params.dart';

class ResetPassword {
  final AuthRepository repository;

  const ResetPassword(this.repository);

  Future<void> call(EmailOnlyParams params) async {
    if (params.email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }

    return repository.resetPassword(params.email);
  }
} 