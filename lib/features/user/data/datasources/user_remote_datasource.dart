import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';

abstract class UserRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String userId);
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile);
  Future<void> deleteAccount(String userId);
  Future<void> updateLastSeen(String userId);
  Future<void> updatePreferences(String userId, List<String> preferences);
  Future<void> updateSettings(String userId, Map<String, dynamic> settings);
  Future<Map<String, dynamic>> getUserStats(String userId);
  Stream<UserProfileModel> userProfileChanges(String userId);
}

class FirebaseUserDataSource implements UserRemoteDataSource {
  final FirebaseFirestore _firestore;
  
  FirebaseUserDataSource({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection => 
      _firestore.collection('users');

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (!doc.exists) {
      throw Exception('User profile not found');
    }
    return UserProfileModel.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });
  }

  @override
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    final docRef = _usersCollection.doc(profile.id);
    final data = profile.toJson()
      ..remove('id'); // Remove ID from data as it's part of the document path
    
    await docRef.update(data);
    return profile;
  }

  @override
  Future<void> deleteAccount(String userId) async {
    await _usersCollection.doc(userId).delete();
  }

  @override
  Future<void> updateLastSeen(String userId) async {
    await _usersCollection.doc(userId).update({
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updatePreferences(String userId, List<String> preferences) async {
    await _usersCollection.doc(userId).update({
      'preferences': preferences,
    });
  }

  @override
  Future<void> updateSettings(String userId, Map<String, dynamic> settings) async {
    await _usersCollection.doc(userId).update({
      'settings': settings,
    });
  }

  @override
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (!doc.exists) {
      throw Exception('User profile not found');
    }
    
    final data = doc.data()!;
    return {
      'notesCount': data['notesCount'] ?? 0,
      // Add other stats as needed
    };
  }

  @override
  Stream<UserProfileModel> userProfileChanges(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('User profile not found');
      }
      return UserProfileModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    });
  }
} 