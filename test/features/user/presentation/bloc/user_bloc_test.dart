import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/user/domain/entities/user_profile.dart';
import 'package:jumblebook/features/user/domain/repositories/user_repository.dart';
import 'package:jumblebook/features/user/domain/usecases/usecases.dart' as usecases;
import 'package:jumblebook/features/user/presentation/bloc/user_bloc.dart';
import 'package:jumblebook/features/user/presentation/bloc/user_event.dart';
import 'package:jumblebook/features/user/presentation/bloc/user_state.dart';

class MockUserRepository extends Mock implements UserRepository {}
class MockGetUserProfile extends Mock implements usecases.GetUserProfile {}
class MockUpdateUserProfile extends Mock implements usecases.UpdateUserProfile {}
class MockDeleteAccount extends Mock implements usecases.DeleteAccount {}

// Register fallback values for Mocktail
class FakeUserProfile extends Fake implements UserProfile {}

void main() {
  late UserBloc userBloc;
  late MockUserRepository userRepository;
  late MockGetUserProfile getUserProfile;
  late MockUpdateUserProfile updateUserProfile;
  late MockDeleteAccount deleteAccount;

  // Test user profile fixture
  final testProfile = UserProfile(
    id: 'test-id',
    email: 'test@example.com',
    displayName: 'Test User',
    bio: 'Test bio',
    notesCount: 5,
    preferences: ['dark_mode', 'notifications_enabled'],
    settings: {'theme': 'dark', 'fontSize': 14},
  );

  setUpAll(() {
    registerFallbackValue(FakeUserProfile());
  });

  setUp(() {
    userRepository = MockUserRepository();
    getUserProfile = MockGetUserProfile();
    updateUserProfile = MockUpdateUserProfile();
    deleteAccount = MockDeleteAccount();

    userBloc = UserBloc(
      getUserProfile: getUserProfile,
      updateUserProfile: updateUserProfile,
      deleteAccount: deleteAccount,
      userRepository: userRepository,
    );
  });

  tearDown(() {
    userBloc.close();
  });

  test('initial state is UserInitial', () {
    expect(userBloc.state, isA<UserInitial>());
  });

  group('LoadUserProfile', () {
    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoaded] when profile is loaded successfully',
      build: () {
        when(() => getUserProfile.call(any())).thenAnswer((_) async => testProfile);
        return userBloc;
      },
      act: (bloc) => bloc.add(const LoadUserProfile('test-id')),
      expect: () => [
        const UserLoading(),
        UserLoaded(testProfile),
      ],
      verify: (_) {
        verify(() => getUserProfile.call('test-id')).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when loading fails',
      build: () {
        when(() => getUserProfile.call(any()))
            .thenThrow(Exception('Failed to load profile'));
        return userBloc;
      },
      act: (bloc) => bloc.add(const LoadUserProfile('test-id')),
      expect: () => [
        const UserLoading(),
        const UserError('Exception: Failed to load profile'),
      ],
    );
  });

  group('UpdateUserProfile', () {
    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoaded] when profile is updated successfully',
      build: () {
        when(() => updateUserProfile.call(any()))
            .thenAnswer((_) async => testProfile);
        return userBloc;
      },
      act: (bloc) => bloc.add(UpdateUserProfile(testProfile)),
      expect: () => [
        const UserLoading(),
        UserLoaded(testProfile),
      ],
      verify: (_) {
        verify(() => updateUserProfile.call(testProfile)).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when update fails',
      build: () {
        when(() => updateUserProfile.call(any()))
            .thenThrow(Exception('Failed to update profile'));
        return userBloc;
      },
      act: (bloc) => bloc.add(UpdateUserProfile(testProfile)),
      expect: () => [
        const UserLoading(),
        const UserError('Exception: Failed to update profile'),
      ],
    );
  });

  group('DeleteUserAccount', () {
    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserDeleted] when account is deleted successfully',
      build: () {
        when(() => deleteAccount.call(any())).thenAnswer((_) async => null);
        return userBloc;
      },
      act: (bloc) => bloc.add(const DeleteUserAccount('test-id')),
      expect: () => [
        const UserLoading(),
        const UserDeleted(),
      ],
      verify: (_) {
        verify(() => deleteAccount.call('test-id')).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when deletion fails',
      build: () {
        when(() => deleteAccount.call(any()))
            .thenThrow(Exception('Failed to delete account'));
        return userBloc;
      },
      act: (bloc) => bloc.add(const DeleteUserAccount('test-id')),
      expect: () => [
        const UserLoading(),
        const UserError('Exception: Failed to delete account'),
      ],
    );
  });

  group('UpdateUserPreferences', () {
    final newPreferences = ['dark_mode', 'notifications_disabled'];

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserPreferencesUpdated] when preferences are updated successfully',
      build: () {
        when(() => userRepository.updatePreferences(any(), any()))
            .thenAnswer((_) async => null);
        when(() => getUserProfile.call(any()))
            .thenAnswer((_) async => testProfile.copyWith(
                  preferences: newPreferences,
                ));
        return userBloc;
      },
      act: (bloc) => bloc.add(UpdateUserPreferences(
        userId: 'test-id',
        preferences: newPreferences,
      )),
      expect: () => [
        const UserLoading(),
        UserPreferencesUpdated(
          testProfile.copyWith(preferences: newPreferences),
        ),
      ],
      verify: (_) {
        verify(() => userRepository.updatePreferences('test-id', newPreferences))
            .called(1);
        verify(() => getUserProfile.call('test-id')).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when preferences update fails',
      build: () {
        when(() => userRepository.updatePreferences(any(), any()))
            .thenThrow(Exception('Failed to update preferences'));
        return userBloc;
      },
      act: (bloc) => bloc.add(UpdateUserPreferences(
        userId: 'test-id',
        preferences: newPreferences,
      )),
      expect: () => [
        const UserLoading(),
        const UserError('Exception: Failed to update preferences'),
      ],
    );
  });

  group('UpdateUserSettings', () {
    final newSettings = {'theme': 'light', 'fontSize': 16};

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserSettingsUpdated] when settings are updated successfully',
      build: () {
        when(() => userRepository.updateSettings(any(), any()))
            .thenAnswer((_) async => null);
        when(() => getUserProfile.call(any()))
            .thenAnswer((_) async => testProfile.copyWith(
                  settings: newSettings,
                ));
        return userBloc;
      },
      act: (bloc) => bloc.add(UpdateUserSettings(
        userId: 'test-id',
        settings: newSettings,
      )),
      expect: () => [
        const UserLoading(),
        UserSettingsUpdated(
          testProfile.copyWith(settings: newSettings),
        ),
      ],
      verify: (_) {
        verify(() => userRepository.updateSettings('test-id', newSettings))
            .called(1);
        verify(() => getUserProfile.call('test-id')).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when settings update fails',
      build: () {
        when(() => userRepository.updateSettings(any(), any()))
            .thenThrow(Exception('Failed to update settings'));
        return userBloc;
      },
      act: (bloc) => bloc.add(UpdateUserSettings(
        userId: 'test-id',
        settings: newSettings,
      )),
      expect: () => [
        const UserLoading(),
        const UserError('Exception: Failed to update settings'),
      ],
    );
  });

  group('UpdateLastSeen', () {
    blocTest<UserBloc, UserState>(
      'does not emit new states when last seen is updated successfully',
      build: () {
        when(() => userRepository.updateLastSeen(any()))
            .thenAnswer((_) async => null);
        return userBloc;
      },
      act: (bloc) => bloc.add(const UpdateLastSeen('test-id')),
      expect: () => [], // No state changes expected
      verify: (_) {
        verify(() => userRepository.updateLastSeen('test-id')).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'does not emit new states when last seen update fails',
      build: () {
        when(() => userRepository.updateLastSeen(any()))
            .thenThrow(Exception('Failed to update last seen'));
        return userBloc;
      },
      act: (bloc) => bloc.add(const UpdateLastSeen('test-id')),
      expect: () => [], // No state changes expected even on failure
    );
  });

  group('Profile Changes Subscription', () {
    blocTest<UserBloc, UserState>(
      'starts listening to profile changes',
      build: () {
        when(() => userRepository.userProfileChanges(any()))
            .thenAnswer((_) => Stream.value(testProfile));
        when(() => getUserProfile.call(any())).thenAnswer((_) async => testProfile);
        return userBloc;
      },
      act: (bloc) => bloc.add(const StartListeningToUserProfile('test-id')),
      verify: (_) {
        verify(() => userRepository.userProfileChanges('test-id')).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'stops listening to profile changes',
      build: () {
        when(() => userRepository.userProfileChanges(any()))
            .thenAnswer((_) => Stream.value(testProfile));
        return userBloc;
      },
      act: (bloc) async {
        bloc.add(const StartListeningToUserProfile('test-id'));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(StopListeningToUserProfile());
      },
      wait: const Duration(milliseconds: 20),
      verify: (_) {
        verify(() => userRepository.userProfileChanges('test-id')).called(1);
      },
    );
  });
} 