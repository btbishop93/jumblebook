import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

sealed class UserState extends Equatable {
  final UserProfile? profile;
  final String? errorMessage;
  final bool isLoading;

  const UserState({
    this.profile,
    this.errorMessage,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [profile, errorMessage, isLoading];
}

final class UserInitial extends UserState {
  const UserInitial() : super();
}

final class UserLoading extends UserState {
  const UserLoading({super.profile}) : super(isLoading: true);
}

final class UserLoaded extends UserState {
  const UserLoaded(UserProfile profile) : super(profile: profile);
}

final class UserError extends UserState {
  const UserError(String message, {super.profile})
      : super(errorMessage: message);
}

final class UserDeleted extends UserState {
  const UserDeleted() : super();
}

final class UserPreferencesUpdated extends UserState {
  const UserPreferencesUpdated(UserProfile profile) : super(profile: profile);
}

final class UserSettingsUpdated extends UserState {
  const UserSettingsUpdated(UserProfile profile) : super(profile: profile);
}
