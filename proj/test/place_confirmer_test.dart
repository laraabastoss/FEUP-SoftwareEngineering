import 'package:brain_box/data_modifiers/place_confirmer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'place_confirmer_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseDatabase>(),
  MockSpec<DatabaseReference>(),
  MockSpec<DataSnapshot>()
])
void main() {
  group('Place Confirmer', () {
    late MockFirebaseDatabase _mockDatabase;
    late MockDatabaseReference _mockReference;
    late MockDataSnapshot _mockSnapshot;

    setUp(() {
      _mockDatabase = MockFirebaseDatabase();
      _mockReference = MockDatabaseReference();
      _mockSnapshot = MockDataSnapshot();

      when(_mockDatabase.ref()).thenReturn(_mockReference);
      when(_mockReference.child(any)).thenReturn(_mockReference);
      when(_mockReference.push()).thenReturn(_mockReference);
      when(_mockReference.key).thenReturn('testkey');
      when(_mockReference.get()).thenAnswer((_) => Future.value(_mockSnapshot));
    });

    test('Accept place', () async {
      PlaceConfirmer confirmer =
          PlaceConfirmer(placeKey: 'testkey', db: _mockDatabase);

      await confirmer.acceptPlace();
      verifyInOrder([
        _mockDatabase.ref(),
        _mockReference.child('places'),
        _mockReference.push(),
        _mockReference.key,
        _mockDatabase.ref(),
        _mockReference.child('schedule/testkey'),
        _mockDatabase.ref(),
        _mockReference.child('tags/testkey'),
      ]);
    });

    test('Decline place', () async {
      PlaceConfirmer confirmer =
          PlaceConfirmer(placeKey: 'testkey', db: _mockDatabase);

      await confirmer.declinePlace();
      verifyInOrder([
        _mockDatabase.ref(),
        _mockReference.child('suggested-places/testkey'),
        _mockReference.remove(),
        _mockDatabase.ref(),
        _mockReference.child('schedule/testkey-SUGGESTION'),
        _mockReference.remove(),
        _mockDatabase.ref(),
        _mockReference.child('tags/testkey-SUGGESTION'),
        _mockReference.remove()
      ]);
    });

    test('Object becomes unusable after first function call', () async {
      PlaceConfirmer confirmer =
          PlaceConfirmer(placeKey: 'testkey', db: _mockDatabase);

      await confirmer.acceptPlace();
      reset(_mockDatabase);
      reset(_mockReference);
      verifyNoMoreInteractions(_mockDatabase);
      verifyNoMoreInteractions(_mockReference);
      confirmer.declinePlace();
    });

    test('Object becomes unusable after first function call 2', () async {
      PlaceConfirmer confirmer =
          PlaceConfirmer(placeKey: 'testkey', db: _mockDatabase);

      await confirmer.declinePlace();
      reset(_mockDatabase);
      reset(_mockReference);
      verifyNoMoreInteractions(_mockDatabase);
      verifyNoMoreInteractions(_mockReference);
      confirmer.acceptPlace();
    });
  });
}
