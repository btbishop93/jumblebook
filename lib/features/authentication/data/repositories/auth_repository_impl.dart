import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) {
    return _dataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<User> signUpWithEmailAndPassword(String email, String password) {
    return _dataSource.signUpWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }

  @override
  Future<void> resetPassword(String email) {
    return _dataSource.resetPassword(email);
  }

  @override
  Future<User> signInWithGoogle() {
    return _dataSource.signInWithGoogle();
  }

  @override
  Future<User> signInWithApple() {
    return _dataSource.signInWithApple();
  }

  @override
  Future<User> signInAnonymously() {
    return _dataSource.signInAnonymously();
  }

  @override
  Stream<User?> get authStateChanges => _dataSource.authStateChanges;

  @override
  User? get currentUser => _dataSource.currentUser;

  @override
  Future<void> deleteAccount() {
    return _dataSource.deleteAccount();
  }

  @override
  Future<void> reauthenticateAndDeleteAccount(String email, String password) {
    return _dataSource.reauthenticateAndDeleteAccount(email, password);
  }
}
