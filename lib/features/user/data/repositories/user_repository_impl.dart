import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_profile_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    return _remoteDataSource.getUserProfile(userId);
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    final userModel = UserProfileModel.fromUserProfile(profile);
    return _remoteDataSource.updateUserProfile(userModel);
  }

  @override
  Future<void> deleteAccount(String userId) async {
    return _remoteDataSource.deleteAccount(userId);
  }

  @override
  Future<void> updateLastSeen(String userId) async {
    return _remoteDataSource.updateLastSeen(userId);
  }

  @override
  Future<void> updatePreferences(String userId, List<String> preferences) async {
    return _remoteDataSource.updatePreferences(userId, preferences);
  }

  @override
  Future<void> updateSettings(String userId, Map<String, dynamic> settings) async {
    return _remoteDataSource.updateSettings(userId, settings);
  }

  @override
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    return _remoteDataSource.getUserStats(userId);
  }

  @override
  Stream<UserProfile> userProfileChanges(String userId) {
    return _remoteDataSource.userProfileChanges(userId);
  }
} 