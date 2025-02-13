import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';
import 'package:jumblebook/features/user/domain/entities/user_profile.dart';
import 'package:jumblebook/features/user/domain/repositories/user_repository.dart';
import 'package:jumblebook/features/user/domain/usecases/usecases.dart' as usecases;
import 'package:jumblebook/features/user/presentation/bloc/user_bloc.dart';
import 'package:jumblebook/features/user/presentation/bloc/user_event.dart';
import 'package:jumblebook/features/user/presentation/bloc/user_state.dart';

class MockGetUserProfile extends Mock implements usecases.GetUserProfile {}
class MockUpdateUserProfile extends Mock implements usecases.UpdateUserProfile {}
class MockDeleteAccount extends Mock implements usecases.DeleteAccount {}
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late UserBloc userBloc;
  late MockGetUserProfile mockGetUserProfile;
  late MockUpdateUserProfile mockUpdateUserProfile;
  late MockDeleteAccount mockDeleteAccount;
  late MockUserRepository mockUserRepository;

  final testUserId = 'test-user-id';
  final testUserProfile = UserProfile(
    id: testUserId,
    email: 'test@example.com',
    displayName: 'Test User',
    bio: 'Test bio',
    lastSeen: DateTime.now(),
    notesCount: 5,
    preferences: ['dark_mode', 'notifications_on'],
    settings: {'theme': 'dark', 'fontSize': 14},
  );

  setUp(() {
    mockGetUserProfile = MockGetUserProfile();
    mockUpdateUserProfile = MockUpdateUserProfile();
    mockDeleteAccount = MockDeleteAccount();
    mockUserRepository = MockUserRepository();

    userBloc = UserBloc(
      getUserProfile: mockGetUserProfile,
      updateUserProfile: mockUpdateUserProfile,
      deleteAccount: mockDeleteAccount,
      userRepository: mockUserRepository,
    );
  });

  tearDown(() {
    userBloc.close();
  });

  test('initial state should be UserInitial', () {
    expect(userBloc.state, const UserInitial());
  });

  group('LoadUserProfile', () {
    test('emits [UserLoading, UserLoaded] when successful', () async {
      // Arrange
      when(() => mockGetUserProfile(testUserId))
          .thenAnswer((_) async => testUserProfile);

      // Assert
      expect(
        userBloc.stream,
        emitsInOrder([
          isA<UserLoading>(),
          UserLoaded(testUserProfile),
        ]),
      );

      // Act
      userBloc.add(LoadUserProfile(testUserId));
    });

    test('emits [UserLoading, UserError] when loading fails', () async {
      // Arrange
      final error = Exception('Failed to load user profile');
      when(() => mockGetUserProfile(testUserId)).thenThrow(error);

      // Assert
      expect(
        userBloc.stream,
        emitsInOrder([
          isA<UserLoading>(),
          isA<UserError>().having(
            (state) => state.errorMessage,
            'error message',
            error.toString(),
          ),
        ]),
      );

      // Act
      userBloc.add(LoadUserProfile(testUserId));
    });
  });

  group('UpdateUserProfile', () {
    test('emits [UserLoading, UserLoaded] when successful', () async {
      // Arrange
      when(() => mockUpdateUserProfile(testUserProfile))
          .thenAnswer((_) async => testUserProfile);

      // Assert
      expect(
        userBloc.stream,
        emitsInOrder([
          isA<UserLoading>(),
          UserLoaded(testUserProfile),
        ]),
      );

      // Act
      userBloc.add(UpdateUserProfile(testUserProfile));
    });

    test('emits [UserLoading, UserError] when update fails', () async {
      // Arrange
      final error = Exception('Failed to update user profile');
      when(() => mockUpdateUserProfile(testUserProfile)).thenThrow(error);

      // Assert
      expect(
        userBloc.stream,
        emitsInOrder([
          isA<UserLoading>(),
          isA<UserError>().having(
            (state) => state.errorMessage,
            'error message',
            error.toString(),
          ),
        ]),
      );

      // Act
      userBloc.add(UpdateUserProfile(testUserProfile));
    });
  });

  group('DeleteUserAccount', () {
    test('emits [UserLoading, UserDeleted] when successful', () async {
      // Arrange
      when(() => mockDeleteAccount(testUserId))
          .thenAnswer((_) async => null);

      // Assert
      expect(
        userBloc.stream,
        emitsInOrder([
          isA<UserLoading>(),
          const UserDeleted(),
        ]),
      );

      // Act
      userBloc.add(DeleteUserAccount(testUserId));
    });

    test('emits [UserLoading, UserError] when deletion fails', () async {
      // Arrange
      final error = Exception('Failed to delete account');
      when(() => mockDeleteAccount(testUserId)).thenThrow(error);

      // Assert
      expect(
        userBloc.stream,
        emitsInOrder([
          isA<UserLoading>(),
          isA<UserError>().having(
            (state) => state.errorMessage,
            'error message',
            error.toString(),
          ),
        ]),
      );

      // Act
      userBloc.add(DeleteUserAccount(testUserId));
    });
  });

  group('UpdateUserPreferences', () {
    final newPreferences = ['dark_mode', 'notifications_off'];

    test('emits [UserLoading, UserPreferencesUpdated] when successful', () async {
      // Arrange
      when(() => mockUserRepository.updatePreferences(testUserId, newPreferences))
          .thenAnswer((_) async => null);
      when(() => mockGetUserProfile(testUserId))
          .thenAnswer((_) async => testUserProfile);

      // Assert
      expect(
        userBloc.stream,
        emitsInOrder([
          isA<UserLoading>(),
          UserPreferencesUpdated(testUserProfile),
        ]),
      );

      // Act
      userBloc.add(UpdateUserPreferences(
        userId: testUserId,
        preferences: newPreferences,
      ));
    });

    test('emits [UserLoading, UserError] when update fails', () async {
      // Arrange
      final error = Exception('Failed to update preferences');
      when(() => mockUserRepository.updatePreferences(testUserId, newPreferences))
          .thenThrow(error);

      // Assert
      expect(
        userBloc.stream,
        emitsInOrder([
          isA<UserLoading>(),
          isA<UserError>().having(
            (state) => state.errorMessage,
            'error message',
            error.toString(),
          ),
        ]),
      );

      // Act
      userBloc.add(UpdateUserPreferences(
        userId: testUserId,
        preferences: newPreferences,
      ));
    });
  });

  group('UpdateUserSettings', () {
    final newSettings = {'theme': 'light', 'fontSize': 16};

    test('emits [UserLoading, UserSettingsUpdated] when successful', () async {
      // Arrange
      when(() => mockUserRepository.updateSettings(testUserId, newSettings))
          .thenAnswer((_) async => null);
      when(() => mockGetUserProfile(testUserId))
          .thenAnswer((_) async => testUserProfile);

      // Assert
      expect(
        userBloc.stream,
        emitsInOrder([
          isA<UserLoading>(),
          UserSettingsUpdated(testUserProfile),
        ]),
      );

      // Act
      userBloc.add(UpdateUserSettings(
        userId: testUserId,
        settings: newSettings,
      ));
    });

    test('emits [UserLoading, UserError] when update fails', () async {
      // Arrange
      final error = Exception('Failed to update settings');
      when(() => mockUserRepository.updateSettings(testUserId, newSettings))
          .thenThrow(error);

      // Assert
      expect(
        userBloc.stream,
        emitsInOrder([
          isA<UserLoading>(),
          isA<UserError>().having(
            (state) => state.errorMessage,
            'error message',
            error.toString(),
          ),
        ]),
      );

      // Act
      userBloc.add(UpdateUserSettings(
        userId: testUserId,
        settings: newSettings,
      ));
    });
  });

  group('UpdateLastSeen', () {
    test('does not emit new states when successful', () async {
      // Arrange
      when(() => mockUserRepository.updateLastSeen(testUserId))
          .thenAnswer((_) async => null);

      // Assert
      expect(
        userBloc.stream,
        emitsInOrder([]), // No state changes expected
      );

      // Act
      userBloc.add(UpdateLastSeen(testUserId));
    });

    test('does not emit new states when last seen update fails', () async {
      // Arrange
      final error = Exception('Failed to update last seen');
      when(() => mockUserRepository.updateLastSeen(testUserId))
          .thenThrow(error);

      // Assert
      expect(
        userBloc.stream,
        emitsInOrder([]), // No state changes expected
      );

      // Act
      userBloc.add(UpdateLastSeen(testUserId));
    });
  });

  group('StartListeningToUserProfile', () {
    test('loads initial profile and starts listening', () async {
      // Arrange
      when(() => mockGetUserProfile(testUserId))
          .thenAnswer((_) async => testUserProfile);
      when(() => mockUserRepository.userProfileChanges(testUserId))
          .thenAnswer((_) => const Stream.empty());

      // Act
      userBloc.add(StartListeningToUserProfile(testUserId));

      // Assert - verify initial load
      await expectLater(
        userBloc.stream,
        emitsInOrder([
          isA<UserLoading>(),
          UserLoaded(testUserProfile),
        ]),
      );

      // Verify stream was subscribed to
      verify(() => mockUserRepository.userProfileChanges(testUserId)).called(1);
    });

    test('handles stream errors', () async {
      // Arrange
      final error = Exception('Stream error');
      when(() => mockGetUserProfile(testUserId))
          .thenAnswer((_) async => testUserProfile);
      when(() => mockUserRepository.userProfileChanges(testUserId))
          .thenAnswer((_) => Stream.error(error));

      // Act
      userBloc.add(StartListeningToUserProfile(testUserId));

      // Assert
      await expectLater(
        userBloc.stream,
        emitsInOrder([
          isA<UserLoading>(),
          UserLoaded(testUserProfile),
          isA<UserError>(),
        ]),
      );
    });

    test('processes stream updates', () async {
      // Arrange
      final streamController = StreamController<UserProfile>();
      final updatedProfile = UserProfile(
        id: testUserId,
        email: 'test@example.com',
        displayName: 'Updated Name',
        bio: 'Test bio',
        lastSeen: DateTime.now(),
        notesCount: 5,
        preferences: ['dark_mode', 'notifications_on'],
        settings: {'theme': 'dark', 'fontSize': 14},
      );

      when(() => mockGetUserProfile(testUserId))
          .thenAnswer((_) async => testUserProfile);
      when(() => mockUserRepository.userProfileChanges(testUserId))
          .thenAnswer((_) => streamController.stream);

      // Act & Assert - Initial load
      userBloc.add(StartListeningToUserProfile(testUserId));
      await expectLater(
        userBloc.stream,
        emitsInOrder([
          isA<UserLoading>(),
          UserLoaded(testUserProfile),
        ]),
      );

      // Act & Assert - Stream update
      when(() => mockGetUserProfile(testUserId))
          .thenAnswer((_) async => updatedProfile);
      streamController.add(updatedProfile);

      await expectLater(
        userBloc.stream,
        emitsInOrder([
          isA<UserLoading>(),
          UserLoaded(updatedProfile),
        ]),
      );

      // Clean up
      await streamController.close();
    });
  });

  group('StopListeningToUserProfile', () {
    test('stops listening to user profile changes', () async {
      // Arrange
      final controller = StreamController<UserProfile>();
      when(() => mockUserRepository.userProfileChanges(testUserId))
          .thenAnswer((_) => controller.stream);
      when(() => mockGetUserProfile(testUserId))
          .thenAnswer((_) async => testUserProfile);

      // Act
      userBloc.add(StartListeningToUserProfile(testUserId));
      await Future.delayed(const Duration(milliseconds: 100));
      userBloc.add(StopListeningToUserProfile());
      await Future.delayed(const Duration(milliseconds: 100));

      // Try to add more data after stopping
      controller.add(testUserProfile);

      // Assert - No new states should be emitted after stopping
      await expectLater(
        userBloc.stream,
        emitsInOrder([]),
      );

      // Clean up
      await controller.close();
    });
  });
} 