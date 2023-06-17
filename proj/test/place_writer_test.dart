import 'package:brain_box/data_modifiers/place_writer.dart';
import 'package:brain_box/providers/tags_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'place_writer_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseDatabase>(),
  MockSpec<DatabaseReference>(),
])
void main() {
  group('Place writer', () {
    late MockFirebaseDatabase _mockDatabase;
    late MockDatabaseReference _mockReference;

    setUp(() {
      _mockDatabase = MockFirebaseDatabase();
      _mockReference = MockDatabaseReference();

      when(_mockDatabase.ref()).thenReturn(_mockReference);
      when(_mockReference.child(any)).thenReturn(_mockReference);
      when(_mockReference.push()).thenReturn(_mockReference);
      when(_mockReference.key).thenReturn('newplace');
    });

    test('Suggest place without schedule or tags', () {
      PlaceWriter writer = PlaceWriter(
          name: 'test',
          city: 'testcity',
          latitude: 40.0,
          longitude: -8.0,
          db: _mockDatabase);

      writer.createPlace();
      verifyInOrder([
        _mockDatabase.ref(),
        _mockReference.child('suggested-places'),
        _mockReference.push(),
        _mockReference.key,
        _mockReference.set({
          'lat': 40.0,
          'long': -8.0,
          'name': 'test',
          'city': 'testcity',
          'comments': 0,
          'rate': 0,
          'tags': 'none'
        })
      ]);
    });

    test('Suggest place without schedule with tags', () {
      PlaceWriter writer = PlaceWriter(
          name: 'test',
          city: 'testcity',
          latitude: 40.0,
          longitude: -8.0,
          db: _mockDatabase);

      writer.createPlace();
      writer.addTags(List.from([Tag(name: 'tag1'), Tag(name: 'tag2')]));
      verifyInOrder([
        _mockDatabase.ref(),
        _mockReference.child('suggested-places'),
        _mockReference.push(),
        _mockReference.key,
        _mockReference.set({
          'lat': 40.0,
          'long': -8.0,
          'name': 'test',
          'city': 'testcity',
          'comments': 0,
          'rate': 0,
          'tags': 'none'
        }),
        _mockDatabase.ref(),
        _mockReference.child('tags/newplace-SUGGESTION'),
        _mockReference.set({
          'tag0': {'name': 'tag1'},
          'tag1': {'name': 'tag2'}
        })
      ]);
    });

    test('Suggest place with schedule and no tags', () {
      PlaceWriter writer = PlaceWriter(
          name: 'test',
          city: 'testcity',
          latitude: 40.0,
          longitude: -8.0,
          db: _mockDatabase);

      List<TimeOfDay> schedule = [];
      for (int i = 0; i < 14; i++) {
        schedule.add(TimeOfDay(hour: i, minute: i + 1));
      }

      writer.createPlace();
      writer.addSchedule(schedule);
      verifyInOrder([
        _mockDatabase.ref(),
        _mockReference.child('suggested-places'),
        _mockReference.push(),
        _mockReference.key,
        _mockReference.set({
          'lat': 40.0,
          'long': -8.0,
          'name': 'test',
          'city': 'testcity',
          'comments': 0,
          'rate': 0,
          'tags': 'none'
        }),
        _mockDatabase.ref(),
        _mockReference.child('schedule/newplace-SUGGESTION'),
        _mockReference.set({
          'amonday': {'endhour': '1h2', 'id': 1, 'starthour': '0h1'},
          'btuesday': {'endhour': '3h4', 'id': 2, 'starthour': '2h3'},
          'cwednesday': {'endhour': '5h6', 'id': 3, 'starthour': '4h5'},
          'dthursday': {'endhour': '7h8', 'id': 4, 'starthour': '6h7'},
          'efriday': {'endhour': '9h10', 'id': 5, 'starthour': '8h9'},
          'fsaturday': {'endhour': '11h12', 'id': 6, 'starthour': '10h11'},
          'gsunday': {'endhour': '13h14', 'id': 7, 'starthour': '12h13'}
        })
      ]);
    });

    test('Write place with schedule and tags', () {
      PlaceWriter writer = PlaceWriter(
          name: 'test',
          city: 'testcity',
          latitude: 40.0,
          longitude: -8.0,
          db: _mockDatabase);

      List<TimeOfDay> schedule = [];
      for (int i = 0; i < 14; i++) {
        schedule.add(TimeOfDay(hour: i, minute: i + 1));
      }

      writer.createPlace();
      writer.addSchedule(schedule);
      writer.addTags(List.from([Tag(name: 'tag1'), Tag(name: 'tag2')]));
      verifyInOrder([
        _mockDatabase.ref(),
        _mockReference.child('suggested-places'),
        _mockReference.push(),
        _mockReference.key,
        _mockReference.set({
          'lat': 40.0,
          'long': -8.0,
          'name': 'test',
          'city': 'testcity',
          'comments': 0,
          'rate': 0,
          'tags': 'none'
        }),
        _mockDatabase.ref(),
        _mockReference.child('schedule/newplace-SUGGESTION'),
        _mockReference.set({
          'amonday': {'endhour': '1h2', 'id': 1, 'starthour': '0h1'},
          'btuesday': {'endhour': '3h4', 'id': 2, 'starthour': '2h3'},
          'cwednesday': {'endhour': '5h6', 'id': 3, 'starthour': '4h5'},
          'dthursday': {'endhour': '7h8', 'id': 4, 'starthour': '6h7'},
          'efriday': {'endhour': '9h10', 'id': 5, 'starthour': '8h9'},
          'fsaturday': {'endhour': '11h12', 'id': 6, 'starthour': '10h11'},
          'gsunday': {'endhour': '13h14', 'id': 7, 'starthour': '12h13'}
        }),
        _mockDatabase.ref(),
        _mockReference.child('tags/newplace-SUGGESTION'),
        _mockReference.set({
          'tag0': {'name': 'tag1'},
          'tag1': {'name': 'tag2'}
        })
      ]);
    });
  });
}
