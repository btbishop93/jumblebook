import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jumblebook/features/notes/data/models/note_model.dart';

void main() {
  final testDate = DateTime(2024);
  final testTimestamp = Timestamp.fromDate(testDate);

  final testNoteModel = NoteModel(
    id: 'test-id',
    title: 'Test Note',
    content: 'Test content',
    date: testDate,
    isEncrypted: false,
    password: '',
    lockCounter: 0,
  );

  final testJson = {
    'id': 'test-id',
    'title': 'Test Note',
    'content': 'Test content',
    'date': testTimestamp,
    'isEncrypted': false,
    'password': '',
    'lockCounter': 0,
    'decryptShift': 0,
  };

  group('fromJson', () {
    test('should return a valid model from JSON', () {
      // Act
      final result = NoteModel.fromJson(testJson);

      // Assert
      expect(result, equals(testNoteModel));
    });

    test('should handle missing optional fields', () {
      // Arrange
      final jsonWithoutOptionals = {
        'id': 'test-id',
        'title': 'Test Note',
        'content': 'Test content',
        'date': testTimestamp,
      };

      // Act
      final result = NoteModel.fromJson(jsonWithoutOptionals);

      // Assert
      expect(result.isEncrypted, isFalse);
      expect(result.password, isEmpty);
      expect(result.lockCounter, isZero);
      expect(result.decryptShift, isZero);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = testNoteModel.toJson();

      // Assert
      expect(result, equals(testJson));
    });

    test('should include encryption fields when note is encrypted', () {
      // Arrange
      final encryptedNoteModel = testNoteModel.copyWith(
        isEncrypted: true,
        password: 'password123',
        lockCounter: 3,
      );

      final expectedJson = Map<String, dynamic>.from(testJson)
        ..update('isEncrypted', (_) => true)
        ..update('password', (_) => 'password123')
        ..update('lockCounter', (_) => 3);

      // Act
      final result = encryptedNoteModel.toJson();

      // Assert
      expect(result, equals(expectedJson));
    });
  });

  group('copyWith', () {
    test('should return a new instance with updated values', () {
      // Arrange
      final newDate = DateTime(2025);

      // Act
      final result = testNoteModel.copyWith(
        id: 'new-id',
        title: 'New Title',
        content: 'New content',
        date: newDate,
        isEncrypted: true,
        password: 'newpass',
        lockCounter: 5,
        decryptShift: 3,
      );

      // Assert
      expect(result.id, equals('new-id'));
      expect(result.title, equals('New Title'));
      expect(result.content, equals('New content'));
      expect(result.date, equals(newDate));
      expect(result.isEncrypted, isTrue);
      expect(result.password, equals('newpass'));
      expect(result.lockCounter, equals(5));
      expect(result.decryptShift, equals(3));
    });

    test('should retain original values when not specified', () {
      // Act
      final result = testNoteModel.copyWith();

      // Assert
      expect(result, equals(testNoteModel));
    });
  });

  group('equality', () {
    test('should be equal when all properties match', () {
      // Arrange
      final noteModel1 = NoteModel(
        id: 'test-id',
        title: 'Test Note',
        content: 'Test content',
        date: testDate,
      );

      final noteModel2 = NoteModel(
        id: 'test-id',
        title: 'Test Note',
        content: 'Test content',
        date: testDate,
      );

      // Assert
      expect(noteModel1, equals(noteModel2));
    });

    test('should not be equal when any property differs', () {
      // Arrange
      final differentNote = testNoteModel.copyWith(
        id: 'different-id',
      );

      // Assert
      expect(testNoteModel, isNot(equals(differentNote)));
    });
  });

  group('toString', () {
    test('should return a string representation of the note model', () {
      // Act
      final result = testNoteModel.toString();

      // Assert
      expect(result, contains('NoteModel'));
      expect(result, contains('test-id'));
      expect(result, contains('Test Note'));
      expect(result, contains('Test content'));
    });
  });
}
