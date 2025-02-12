import '../entities/user_profile.dart';
import '../repositories/user_repository.dart';

class UpdateUserProfile {
  final UserRepository repository;

  const UpdateUserProfile(this.repository);

  Future<UserProfile> call(UserProfile profile) async {
    if (profile.id.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (profile.email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }
    return repository.updateUserProfile(profile);
  }
} 