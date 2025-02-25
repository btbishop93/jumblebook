import '../../domain/entities/user.dart';

class AuthData {
  final User? user;
  final String? errorMessage;
  final bool isLoading;
  final bool isAuthenticated;
  final String? email; // Useful for remembering email between states
  final bool isEmailVerified;

  const AuthData({
    this.user,
    this.errorMessage,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.email,
    this.isEmailVerified = false,
  });

  AuthData copyWith({
    User? user,
    String? errorMessage,
    bool? isLoading,
    bool? isAuthenticated,
    String? email,
    bool? isEmailVerified,
  }) {
    return AuthData(
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  // Helper method to clear errors
  AuthData clearError() {
    return copyWith(errorMessage: null);
  }

  // Helper method to reset state
  AuthData reset() {
    return const AuthData();
  }
}
