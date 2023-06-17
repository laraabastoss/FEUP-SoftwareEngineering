import 'package:brain_box/providers/comment_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class CommentWriter {
  CommentWriter({required this.placeKey, required this.db, required this.auth});

  final FirebaseDatabase db;
  final FirebaseAuth auth;
  final String placeKey;

  Future<void> writeComment(
      String text, int rating, Comment? currComment) async {
    String? uid = auth.currentUser?.uid;
    if (uid == null) {
      throw TypeError();
    }
    DatabaseReference comments;
    if (currComment == null) {
      DatabaseReference numberComments = db.ref();
      DatabaseReference dbrating = db.ref();
      DataSnapshot snapshot =
          await dbrating.child('places/$placeKey/rate').get();
      DataSnapshot snapshotcomments =
          await dbrating.child('places/$placeKey/comments').get();
      double totalrating = (snapshot.value as num).toDouble();
      double numberofcomments = (snapshotcomments.value as num).toDouble();
      totalrating *= numberofcomments;
      totalrating += rating.toDouble();
      numberComments
          .child('places/$placeKey/comments')
          .set(ServerValue.increment(1));
      totalrating /= (numberofcomments + 1);
      dbrating.child('places/$placeKey/rate').set(totalrating);

      comments = db.ref().child('comments/$placeKey').push();
      numberComments
          .child('places/$placeKey/comments')
          .set(ServerValue.increment(1));
    } else {
      DatabaseReference dbrating = db.ref();
      DataSnapshot snapshot =
          await dbrating.child('places/$placeKey/rate').get();
      DataSnapshot snapshotcomments =
          await dbrating.child('places/$placeKey/comments').get();
      double totalrating = (snapshot.value as num).toDouble();
      double numberofcomments = (snapshotcomments.value as num).toDouble();
      totalrating *= numberofcomments;
      totalrating -= currComment.rating;
      totalrating += rating;
      totalrating /= (numberofcomments);
      String? key = currComment.key;

      comments = db.ref().child('comments/$placeKey/$key');
      dbrating.child('places/$placeKey/rate').set(totalrating);
    }
    Map<dynamic, dynamic> comment = {
      "text": text,
      "rating": rating,
      "uid": uid
    };
    comments.set(comment);
  }
}
