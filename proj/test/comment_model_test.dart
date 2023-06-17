import 'package:brain_box/providers/comment_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'comment_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<FirebaseDatabase>(), MockSpec<DatabaseReference>(), MockSpec<DataSnapshot>(), MockSpec<FirebaseAuth>(), MockSpec<User>(), MockSpec<Stream<DatabaseEvent>>()])

void main() {
  group('CommentModel', () {
    late MockFirebaseDatabase mockFirebaseDatabase;
    late MockDatabaseReference mockDatabaseReference;
    late MockDataSnapshot mockDataSnapshot;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockStream mockStream;

    setUp(() {
      mockFirebaseDatabase = MockFirebaseDatabase();
      mockDatabaseReference = MockDatabaseReference();
      mockDataSnapshot = MockDataSnapshot();
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockStream = MockStream();

      when(mockFirebaseDatabase.ref()).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.child(any)).thenReturn(mockDatabaseReference);
      when(mockDatabaseReference.get())
          .thenAnswer((_) => Future.value(mockDataSnapshot));
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('testUid');
      when(mockDatabaseReference.onValue).thenAnswer((realInvocation) => mockStream);
    });

    test('getUserComment returns null when there are no comments', () async {
      when(mockDataSnapshot.value).thenReturn(null);

      final comment = await CommentModel.getUserComment('testKey', mockFirebaseDatabase, mockFirebaseAuth);

      expect(comment, isNull);
    });

    test('getUserComment returns null when user has not commented', () async {
      when(mockDataSnapshot.value).thenReturn({
        'comment1': {'uid': 'otherUid', 'rating': 3, 'text': 'testtext'}
      });

      final comment = await CommentModel.getUserComment('testKey', mockFirebaseDatabase, mockFirebaseAuth);

      expect(comment, isNull);
    });

    test('getUserComment returns user comment when present', () async {
      when(mockDataSnapshot.value).thenReturn({
        'comment1': {'uid': 'testUid', 'rating': 5, 'text': 'test'}
      });

      final comment = await CommentModel.getUserComment('testKey', mockFirebaseDatabase, mockFirebaseAuth);

      expect(comment!.rating, equals(5));
      expect(comment.text, equals('test'));
    });

    test('Constructor', () {
      CommentModel model = CommentModel('test', mockDatabaseReference);

      verifyInOrder([
        mockDatabaseReference.child('comments/test'),
        mockDatabaseReference.onValue,
        mockStream.listen(any)
      ]);
    });
  });
}
