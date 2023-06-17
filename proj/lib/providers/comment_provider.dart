import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class Comment {
  Comment(this.key,
      {required this.rating, required this.text, required this.uid});

  final int rating;
  final String text;
  final String uid;
  final String? key;

  static List<Comment> fromRTDB(dynamic data) {
    List<Comment> comments = <Comment>[];
    if (data == null) return comments;
    Map<dynamic, dynamic> rvalues = data as Map<dynamic, dynamic>;
    rvalues.forEach((key, value) {
      comments.add(Comment(key,
          rating: value["rating"], text: value["text"], uid: value["uid"]));
    });
    return comments;
  }

  @override
  bool operator ==(Object other) {
    return (other is Comment) &&
        ((rating == other.rating) &&
            (text == other.text) &&
            (uid == other.uid));
  }

  @override
  int get hashCode => Object.hash(rating, text, uid);
}

class CommentModel extends ChangeNotifier {
  CommentModel(this.key, this.db) {
    listenToPlaceComments();
  }

  List<Comment> _comments = [];
  final DatabaseReference db;

  List<Comment> get comments => _comments;

  late StreamSubscription<DatabaseEvent> placeStream;
  final String key;

  static Future<Comment?> getUserComment(String placeKey, FirebaseDatabase db, FirebaseAuth auth) async {
    Comment comment;
    DataSnapshot snapshot =
        await db.ref().child('comments/$placeKey').get();
    List<Comment> currentComments = Comment.fromRTDB(snapshot.value);
    for (comment in currentComments) {
      if (comment.uid == auth.currentUser?.uid) {
        return comment;
      }
    }
    return null;
  }

  void listenToPlaceComments() {
    placeStream = db.child('comments/$key').onValue.listen((event) {
      _comments = Comment.fromRTDB(event.snapshot.value);
      notifyListeners();
    });
  }

  void setComment(int rating, String text, String uid) {
    final commentRef = db.child('comments/$key').push();
    commentRef.set({
      'rating': rating,
      'text': text,
      'uid': uid,
    });
  }

  @override
  void dispose() {
    placeStream.cancel();
    super.dispose();
  }
}
