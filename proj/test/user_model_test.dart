import 'package:brain_box/providers/user_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DatabaseReference>(), MockSpec<Stream<DatabaseEvent>>(), MockSpec<FirebaseDatabase>(), MockSpec<DataSnapshot>()])

void main() {
  group('Alltag model', () {
    late MockDatabaseReference _mockReference;
    late MockStream _mockStream;
    late MockFirebaseDatabase _mockDatabase;
    late MockDataSnapshot _mockSnapshot;

    setUp(() {
      _mockReference = MockDatabaseReference();
      _mockStream = MockStream();
      _mockDatabase = MockFirebaseDatabase();
      _mockSnapshot = MockDataSnapshot();

      when(_mockReference.child(any)).thenReturn(_mockReference);
      when(_mockDatabase.ref()).thenReturn(_mockReference);
      when(_mockReference.onValue).thenAnswer((realInvocation) => _mockStream);
    });

    test('Get data', () async {
      when(_mockReference.get()).thenAnswer((realInvocation) => Future.value(_mockSnapshot));
      when(_mockSnapshot.value).thenReturn({'username': 'name', 'email': 'test.123@test.com', 'phone': '934255303', 'bio': 'I am a test', 'isAdmin': true});
      CurrUser user = await UserProvider.getUserData('test', _mockDatabase);

      verifyInOrder([
        _mockReference.child('users/test'),
        _mockReference.get()
      ]);

      expect(user.username, 'name');
      expect(user.email, 'test.123@test.com');
      expect(user.phone, '934255303');
      expect(user.bio, 'I am a test');
      expect(user.isAdmin, true);
    });
  });
}