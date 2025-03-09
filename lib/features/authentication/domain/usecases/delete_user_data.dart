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

    // First delete all notes
    await deleteAllNotes(currentUser.id);
    
    // Then delete the user account
    await authRepository.deleteAccount();
  }
} 