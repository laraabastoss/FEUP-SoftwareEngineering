import 'package:brain_box/data_modifiers/comment_writer.dart';
import 'package:brain_box/providers/comment_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'comment_writer_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseDatabase>(),
  MockSpec<FirebaseAuth>(),
  MockSpec<DatabaseReference>(),
  MockSpec<User>(),
  MockSpec<DataSnapshot>()
])
void main() {
  group('Comment writer', () {
    late MockFirebaseDatabase _mockDatabase;
    late MockDatabaseReference _mockReference;
    late MockFirebaseAuth _mockAuth;
    late MockUser _mockUser;
    late MockDataSnapshot _mockSnapshot;

    setUp(() {
      _mockDatabase = MockFirebaseDatabase();
      _mockReference = MockDatabaseReference();
      _mockAuth = MockFirebaseAuth();
      _mockUser = MockUser();
      _mockSnapshot = MockDataSnapshot();

      when(_mockDatabase.ref()).thenReturn(_mockReference);
      when(_mockReference.push()).thenReturn(_mockReference);
      when(_mockReference.child(any)).thenReturn(_mockReference);
      when(_mockAuth.currentUser).thenReturn(_mockUser);
      when(_mockUser.uid).thenReturn('testuid');
      when(_mockSnapshot.value).thenReturn(20);
      when(_mockReference.get()).thenAnswer((realInvocation) => Future.value(_mockSnapshot));
    });

    test('Writing comment with no previous comment', () async {
      CommentWriter writer =
          CommentWriter(placeKey: 'test', db: _mockDatabase, auth: _mockAuth);

      await writer.writeComment('test', 1, null);
      verifyInOrder([
        _mockAuth.currentUser,
        _mockUser.uid,
        _mockDatabase.ref(),
        _mockDatabase.ref(),
        _mockReference.child('places/test/rate'),
        _mockReference.get(),
        _mockReference.child('places/test/comments'),
        _mockReference.get(),
        _mockSnapshot.value,
        _mockSnapshot.value,
        _mockReference.child('places/test/comments'),
        _mockReference.set(ServerValue.increment(1)),
        _mockReference.child('places/test/rate'),
        _mockReference.set((20 * 20 + 1)/21),
        _mockDatabase.ref(),
        _mockReference.child('comments/test'),
        _mockReference.push(),
        _mockReference.child('places/test/comments'),
        _mockReference.set(ServerValue.increment(1)),
        _mockReference.set({"text": 'test', "rating": 1, "uid": 'testuid'})
      ]);
    });

    test('Writing comment with previous comment', () async {
      CommentWriter writer =
          CommentWriter(placeKey: 'test', db: _mockDatabase, auth: _mockAuth);

      await writer.writeComment('test', 2,
          Comment('testkey', rating: 1, text: 'test', uid: 'testuid'));
      verifyInOrder([
        _mockAuth.currentUser,
        _mockUser.uid,
        _mockDatabase.ref(),
        _mockReference.child('places/test/rate'),
        _mockReference.get(),
        _mockReference.child('places/test/comments'),
        _mockReference.get(),
        _mockSnapshot.value,
        _mockDatabase.ref(),
        _mockReference.child('comments/test/testkey'),
        _mockReference.child('places/test/rate'),
        _mockReference.set(((20 * 20) -1 + 2)/20),
        _mockReference.set({"text": 'test', "rating": 2, "uid": 'testuid'})
      ]);
    });

    test('Writing comment with no authenticated user', () {
      CommentWriter writer =
          CommentWriter(placeKey: 'test', db: _mockDatabase, auth: _mockAuth);
      when(_mockAuth.currentUser).thenReturn(null);
      expect(() => writer.writeComment('test', 1, null),
          throwsA(isA<TypeError>()));
    });
  });
}
