import '../entities/user_profile.dart';

abstract class UserRepository {
  /// Get user profile by ID
  Future<UserProfile> getUserProfile(String userId);

  /// Update user profile
  Future<UserProfile> updateUserProfile(UserProfile profile);

  /// Delete user account and all associated data
  Future<void> deleteAccount(String userId);

  /// Update user last seen timestamp
  Future<void> updateLastSeen(String userId);

  /// Update user preferences
  Future<void> updatePreferences(String userId, List<String> preferences);

  /// Update user settings
  Future<void> updateSettings(String userId, Map<String, dynamic> settings);

  /// Get user statistics (e.g., notes count)
  Future<Map<String, dynamic>> getUserStats(String userId);

  /// Stream of user profile changes
  Stream<UserProfile> userProfileChanges(String userId);
}
