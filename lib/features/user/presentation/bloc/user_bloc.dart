import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/usecases.dart' as usecases;
import '../../domain/entities/user_profile.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final usecases.GetUserProfile _getUserProfile;
  final usecases.UpdateUserProfile _updateUserProfile;
  final usecases.DeleteAccount _deleteAccount;
  final UserRepository _userRepository;
  StreamSubscription<dynamic>? _userProfileSubscription;

  UserBloc({
    required usecases.GetUserProfile getUserProfile,
    required usecases.UpdateUserProfile updateUserProfile,
    required usecases.DeleteAccount deleteAccount,
    required UserRepository userRepository,
  })  : _getUserProfile = getUserProfile,
        _updateUserProfile = updateUserProfile,
        _deleteAccount = deleteAccount,
        _userRepository = userRepository,
        super(const UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<DeleteUserAccount>(_onDeleteUserAccount);
    on<UpdateUserPreferences>(_onUpdateUserPreferences);
    on<UpdateUserSettings>(_onUpdateUserSettings);
    on<UpdateLastSeen>(_onUpdateLastSeen);
    on<StartListeningToUserProfile>(_onStartListeningToUserProfile);
    on<StopListeningToUserProfile>(_onStopListeningToUserProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading(profile: state.profile));
    try {
      final profile = await _getUserProfile(event.userId);
      emit(UserLoaded(profile));
    } catch (e) {
      emit(UserError(e.toString(), profile: state.profile));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading(profile: state.profile));
    try {
      final updatedProfile = await _updateUserProfile(event.profile);
      emit(UserLoaded(updatedProfile));
    } catch (e) {
      emit(UserError(e.toString(), profile: state.profile));
    }
  }

  Future<void> _onDeleteUserAccount(
    DeleteUserAccount event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading(profile: state.profile));
    try {
      await _deleteAccount(event.userId);
      emit(const UserDeleted());
    } catch (e) {
      emit(UserError(e.toString(), profile: state.profile));
    }
  }

  Future<void> _onUpdateUserPreferences(
    UpdateUserPreferences event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading(profile: state.profile));
    try {
      await _userRepository.updatePreferences(
        event.userId,
        event.preferences,
      );
      final updatedProfile = await _getUserProfile(event.userId);
      emit(UserPreferencesUpdated(updatedProfile));
    } catch (e) {
      emit(UserError(e.toString(), profile: state.profile));
    }
  }

  Future<void> _onUpdateUserSettings(
    UpdateUserSettings event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading(profile: state.profile));
    try {
      await _userRepository.updateSettings(
        event.userId,
        event.settings,
      );
      final updatedProfile = await _getUserProfile(event.userId);
      emit(UserSettingsUpdated(updatedProfile));
    } catch (e) {
      emit(UserError(e.toString(), profile: state.profile));
    }
  }

  Future<void> _onUpdateLastSeen(
    UpdateLastSeen event,
    Emitter<UserState> emit,
  ) async {
    try {
      await _userRepository.updateLastSeen(event.userId);
    } catch (e) {
      // Silently fail as this is not critical
      print('Failed to update last seen: $e');
    }
  }

  Future<void> _onStartListeningToUserProfile(
    StartListeningToUserProfile event,
    Emitter<UserState> emit,
  ) async {
    await _userProfileSubscription?.cancel();
    
    try {
      // Initial load
      emit(UserLoading(profile: state.profile));
      final initialProfile = await _getUserProfile(event.userId);
      emit(UserLoaded(initialProfile));
      
      // Start listening to changes
      await emit.forEach<UserProfile>(
        _userRepository.userProfileChanges(event.userId),
        onData: (profile) {
          add(LoadUserProfile(event.userId));
          return state;
        },
        onError: (error, stackTrace) {
          emit(UserError(error.toString(), profile: state.profile));
          return state;
        },
      );
    } catch (e) {
      emit(UserError(e.toString(), profile: state.profile));
    }
  }

  Future<void> _onStopListeningToUserProfile(
    StopListeningToUserProfile event,
    Emitter<UserState> emit,
  ) async {
    await _userProfileSubscription?.cancel();
    _userProfileSubscription = null;
  }

  @override
  Future<void> close() async {
    await _userProfileSubscription?.cancel();
    return super.close();
  }
} 