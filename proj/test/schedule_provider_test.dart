import 'package:brain_box/providers/schedule_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'schedule_provider_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DatabaseReference>(), MockSpec<Stream<DatabaseEvent>>()])

void main() {
  group('Alltag model', () {
    late MockDatabaseReference _mockReference;
    late MockStream _mockStream;

    setUp(() {
      _mockReference = MockDatabaseReference();
      _mockStream = MockStream();

      when(_mockReference.child(any)).thenReturn(_mockReference);
      when(_mockReference.onValue).thenAnswer((realInvocation) => _mockStream);
    });

    test('Constructor', () {
      ScheduleModel model = ScheduleModel('test', _mockReference);

      verifyInOrder([
        _mockReference.child('schedule/test'),
        _mockReference.onValue,
        _mockStream.listen(any)
      ]);
    });
  });
}