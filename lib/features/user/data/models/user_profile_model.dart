import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.bio,
    super.lastSeen,
    super.notesCount = 0,
    super.preferences = const [],
    super.settings = const {},
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
      lastSeen: json['lastSeen'] != null 
          ? (json['lastSeen'] as Timestamp).toDate()
          : null,
      notesCount: json['notesCount'] as int? ?? 0,
      preferences: List<String>.from(json['preferences'] ?? []),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'notesCount': notesCount,
      'preferences': preferences,
      'settings': settings,
    };
  }

  factory UserProfileModel.fromUserProfile(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      email: profile.email,
      displayName: profile.displayName,
      photoUrl: profile.photoUrl,
      bio: profile.bio,
      lastSeen: profile.lastSeen,
      notesCount: profile.notesCount,
      preferences: profile.preferences,
      settings: profile.settings,
    );
  }
} 