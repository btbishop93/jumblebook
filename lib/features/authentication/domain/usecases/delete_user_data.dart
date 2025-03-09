import 'dart:developer' as dev;
import '../../../notes/domain/usecases/delete_all_notes.dart';
import '../repositories/auth_repository.dart';
import 'auth_params.dart';

class DeleteUserData {
  final AuthRepository authRepository;
  final DeleteAllNotes deleteAllNotes;

  const DeleteUserData({
    required this.authRepository,
    required this.deleteAllNotes,
  });

  Future<void> call(NoParams params) async {
    final currentUser = authRepository.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      // First try to delete all notes while the user is still authenticated
      // This operation is wrapped in a try-catch in the data source and won't throw
      await deleteAllNotes(currentUser.id);
      
      // Then delete the user account
      // This might throw a "requires-recent-login" error
      await authRepository.deleteAccount();
    } catch (e) {
      dev.log('Error during account deletion process: $e');
      
      // Check if this is a "requires recent login" error
      if (e.toString().contains('requires-recent-login')) {
        // This error needs to be handled by the UI to prompt for re-authentication
        throw Exception('requires-recent-login');
      }
      
      // Rethrow any other errors
      rethrow;
    }
  }
  
  Future<void> reauthenticateAndDelete(String email, String password) async {
    final currentUser = authRepository.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      // First try to delete all notes while the user is still authenticated
      // This operation is wrapped in a try-catch in the data source and won't throw
      await deleteAllNotes(currentUser.id);
      
      // Then re-authenticate and delete the account
      await authRepository.reauthenticateAndDeleteAccount(email, password);
    } catch (e) {
      dev.log('Error during re-authentication and account deletion: $e');
      rethrow;
    }
  }
} 