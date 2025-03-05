// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/notes/data/datasources/notes_remote_datasource.dart';
import 'package:jumblebook/features/notes/data/models/note_model.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockCountQuerySnapshot extends Mock implements AggregateQuerySnapshot {}

class MockAggregateQuery extends Mock implements AggregateQuery {}

void main() {
  late FirebaseNotesDataSource dataSource;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUsersCollection;
  late MockCollectionReference mockNotesCollection;
  late MockDocumentReference mockUserDocRef;

  final testUserId = 'test-user-id';
  final testNoteId = 'test-note-id';
  final testDate = DateTime(2024);
  final testTimestamp = Timestamp.fromDate(testDate);

  final testNoteModel = NoteModel(
    id: testNoteId,
    title: 'Test Note',
    content: 'Test content',
    date: testDate,
  );

  Map<String, dynamic> createTestNoteJson() => {
        'id': testNoteId,
        'title': 'Test Note',
        'content': 'Test content',
        'decryptShift': 0,
        'isEncrypted': false,
        'lockCounter': 0,
        'password': '',
        'date': testTimestamp,
      };

  bool mapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    return map1.entries.every((entry) {
      final value2 = map2[entry.key];
      if (value2 == null) return false;
      if (entry.value is Timestamp && value2 is Timestamp) {
        return entry.value.seconds == value2.seconds &&
            entry.value.nanoseconds == value2.nanoseconds;
      }
      return entry.value == value2;
    });
  }

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockNotesCollection = MockCollectionReference();
    mockUserDocRef = MockDocumentReference();
    dataSource = FirebaseNotesDataSource(firestore: mockFirestore);

    // Setup collection reference chain
    when(() => mockFirestore.collection('users'))
        .thenReturn(mockUsersCollection);
    when(() => mockUsersCollection.doc(testUserId)).thenReturn(mockUserDocRef);
    when(() => mockUserDocRef.collection('notes'))
        .thenReturn(mockNotesCollection);
  });

  group('getNotes', () {
    test('should return stream of notes from Firestore', () async {
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();

      when(() => mockNotesCollection.snapshots())
          .thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(() => mockQuerySnapshot.docs)
          .thenReturn([mockQueryDocumentSnapshot]);
      when(() => mockQueryDocumentSnapshot.data())
          .thenReturn(createTestNoteJson());
      when(() => mockQueryDocumentSnapshot.id).thenReturn(testNoteId);

      final result = dataSource.getNotes(testUserId);

      await expectLater(result, emits([testNoteModel]));
      verify(() => mockFirestore.collection('users')).called(1);
      verify(() => mockUsersCollection.doc(testUserId)).called(1);
      verify(() => mockUserDocRef.collection('notes')).called(1);
    });

    test('should propagate errors from Firestore', () async {
      final error = Exception('Firestore error');
      when(() => mockNotesCollection.snapshots())
          .thenAnswer((_) => Stream.error(error));

      final result = dataSource.getNotes(testUserId);

      await expectLater(result, emitsError(isA<Exception>()));
    });
  });

  group('getNote', () {
    test('should return note from Firestore', () async {
      final mockDocumentReference = MockDocumentReference();
      final mockDocumentSnapshot = MockDocumentSnapshot();

      when(() => mockNotesCollection.doc(testNoteId))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(() => mockDocumentSnapshot.data()).thenReturn(createTestNoteJson());
      when(() => mockDocumentSnapshot.exists).thenReturn(true);
      when(() => mockDocumentSnapshot.id).thenReturn(testNoteId);

      final result = await dataSource.getNote(testUserId, testNoteId);

      expect(result, equals(testNoteModel));
      verify(() => mockFirestore.collection('users')).called(1);
      verify(() => mockUsersCollection.doc(testUserId)).called(1);
      verify(() => mockUserDocRef.collection('notes')).called(1);
      verify(() => mockNotesCollection.doc(testNoteId)).called(1);
    });

    test('should throw exception when note does not exist', () async {
      final mockDocumentReference = MockDocumentReference();
      final mockDocumentSnapshot = MockDocumentSnapshot();

      when(() => mockNotesCollection.doc(testNoteId))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(() => mockDocumentSnapshot.exists).thenReturn(false);

      expect(
        () => dataSource.getNote(testUserId, testNoteId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('saveNote', () {
    test('should save note to Firestore', () async {
      final mockDocumentReference = MockDocumentReference();

      when(() => mockNotesCollection.doc(testNoteId))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.set(any(), any()))
          .thenAnswer((_) async => Future<void>.value());

      await dataSource.saveNote(testUserId, testNoteModel);

      verify(() => mockFirestore.collection('users')).called(1);
      verify(() => mockUsersCollection.doc(testUserId)).called(1);
      verify(() => mockUserDocRef.collection('notes')).called(1);
      verify(() => mockNotesCollection.doc(testNoteId)).called(1);

      final verifyCall =
          verify(() => mockDocumentReference.set(captureAny(), captureAny()));
      verifyCall.called(1);

      final capturedJson = verifyCall.captured[0] as Map<String, dynamic>;
      final capturedOptions = verifyCall.captured[1] as SetOptions;

      expect(mapsEqual(capturedJson, createTestNoteJson()), isTrue);
      expect(capturedOptions.merge, isTrue);
    });

    test('should propagate errors from Firestore', () async {
      final mockDocumentReference = MockDocumentReference();
      final error = Exception('Firestore error');

      when(() => mockNotesCollection.doc(testNoteId))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.set(any(), any())).thenThrow(error);

      expect(
        () => dataSource.saveNote(testUserId, testNoteModel),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteNote', () {
    test('should delete note from Firestore', () async {
      final mockDocumentReference = MockDocumentReference();

      when(() => mockNotesCollection.doc(testNoteId))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.delete())
          .thenAnswer((_) async => Future<void>.value());

      await dataSource.deleteNote(testUserId, testNoteId);

      verify(() => mockFirestore.collection('users')).called(1);
      verify(() => mockUsersCollection.doc(testUserId)).called(1);
      verify(() => mockUserDocRef.collection('notes')).called(1);
      verify(() => mockNotesCollection.doc(testNoteId)).called(1);
      verify(() => mockDocumentReference.delete()).called(1);
    });

    test('should propagate errors from Firestore', () async {
      final mockDocumentReference = MockDocumentReference();
      final error = Exception('Firestore error');

      when(() => mockNotesCollection.doc(testNoteId))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.delete()).thenThrow(error);

      expect(
        () => dataSource.deleteNote(testUserId, testNoteId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getNoteCount', () {
    test('should return note count from Firestore', () async {
      final mockAggregateQuery = MockAggregateQuery();
      final mockCountQuerySnapshot = MockCountQuerySnapshot();

      when(() => mockNotesCollection.count()).thenReturn(mockAggregateQuery);
      when(() => mockAggregateQuery.get())
          .thenAnswer((_) async => mockCountQuerySnapshot);
      when(() => mockCountQuerySnapshot.count).thenReturn(5);

      final result = await dataSource.getNoteCount(testUserId);

      expect(result, equals(5));
      verify(() => mockFirestore.collection('users')).called(1);
      verify(() => mockUsersCollection.doc(testUserId)).called(1);
      verify(() => mockUserDocRef.collection('notes')).called(1);
    });

    test('should propagate errors from Firestore', () async {
      final mockAggregateQuery = MockAggregateQuery();
      final error = Exception('Firestore error');

      when(() => mockNotesCollection.count()).thenReturn(mockAggregateQuery);
      when(() => mockAggregateQuery.get()).thenThrow(error);

      expect(
        () => dataSource.getNoteCount(testUserId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateLockCounter', () {
    test('should update lock counter in Firestore', () async {
      final mockDocumentReference = MockDocumentReference();
      const lockCounter = 3;

      when(() => mockNotesCollection.doc(testNoteId))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.update(any()))
          .thenAnswer((_) async => Future<void>.value());

      await dataSource.updateLockCounter(testUserId, testNoteId, lockCounter);

      verify(() => mockFirestore.collection('users')).called(1);
      verify(() => mockUsersCollection.doc(testUserId)).called(1);
      verify(() => mockUserDocRef.collection('notes')).called(1);
      verify(() => mockNotesCollection.doc(testNoteId)).called(1);
      verify(() => mockDocumentReference.update({'lockCounter': lockCounter}))
          .called(1);
    });

    test('should propagate errors from Firestore', () async {
      final mockDocumentReference = MockDocumentReference();
      final error = Exception('Firestore error');
      const lockCounter = 3;

      when(() => mockNotesCollection.doc(testNoteId))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.update(any())).thenThrow(error);

      expect(
        () => dataSource.updateLockCounter(testUserId, testNoteId, lockCounter),
        throwsA(isA<Exception>()),
      );
    });
  });
}
