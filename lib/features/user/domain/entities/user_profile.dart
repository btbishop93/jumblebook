import '../../../authentication/domain/entities/user.dart';

class UserProfile extends User {
  final String? bio;
  final DateTime? lastSeen;
  final int notesCount;
  final List<String> preferences;
  final Map<String, dynamic> settings;

  const UserProfile({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.isAnonymous,
    this.bio,
    this.lastSeen,
    this.notesCount = 0,
    this.preferences = const [],
    this.settings = const {},
  });

  @override
  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isAnonymous,
    String? bio,
    DateTime? lastSeen,
    int? notesCount,
    List<String>? preferences,
    Map<String, dynamic>? settings,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      bio: bio ?? this.bio,
      lastSeen: lastSeen ?? this.lastSeen,
      notesCount: notesCount ?? this.notesCount,
      preferences: preferences ?? this.preferences,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        bio,
        lastSeen,
        notesCount,
        preferences,
        settings,
      ];
} 