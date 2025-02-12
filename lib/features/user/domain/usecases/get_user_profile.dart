import '../entities/user_profile.dart';
import '../repositories/user_repository.dart';

class GetUserProfile {
  final UserRepository repository;

  const GetUserProfile(this.repository);

  Future<UserProfile> call(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    return repository.getUserProfile(userId);
  }
} 