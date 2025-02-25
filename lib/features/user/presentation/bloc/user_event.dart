import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

sealed class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

final class LoadUserProfile extends UserEvent {
  final String userId;

  const LoadUserProfile(this.userId);

  @override
  List<Object> get props => [userId];
}

final class UpdateUserProfile extends UserEvent {
  final UserProfile profile;

  const UpdateUserProfile(this.profile);

  @override
  List<Object> get props => [profile];
}

final class DeleteUserAccount extends UserEvent {
  final String userId;

  const DeleteUserAccount(this.userId);

  @override
  List<Object> get props => [userId];
}

final class UpdateUserPreferences extends UserEvent {
  final String userId;
  final List<String> preferences;

  const UpdateUserPreferences({
    required this.userId,
    required this.preferences,
  });

  @override
  List<Object> get props => [userId, preferences];
}

final class UpdateUserSettings extends UserEvent {
  final String userId;
  final Map<String, dynamic> settings;

  const UpdateUserSettings({
    required this.userId,
    required this.settings,
  });

  @override
  List<Object> get props => [userId, settings];
}

final class UpdateLastSeen extends UserEvent {
  final String userId;

  const UpdateLastSeen(this.userId);

  @override
  List<Object> get props => [userId];
}

final class StartListeningToUserProfile extends UserEvent {
  final String userId;

  const StartListeningToUserProfile(this.userId);

  @override
  List<Object> get props => [userId];
}

final class StopListeningToUserProfile extends UserEvent {}
