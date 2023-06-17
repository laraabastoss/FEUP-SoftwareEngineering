import 'package:firebase_database/firebase_database.dart';

class PlaceConfirmer {
  PlaceConfirmer({required this.placeKey, required this.db});

  final String placeKey;
  final FirebaseDatabase db;
  bool isUsed = false;

  Future<void> acceptPlace() async {
    if (isUsed) return;
    isUsed = true;

    DatabaseReference ref = db.ref().child('places').push();
    String? key = ref.key;
    if (key == null) return;
    DatabaseReference schedule = db.ref().child('schedule/$key');
    DatabaseReference tags = db.ref().child('tags/$key');

    Future<DataSnapshot> placeData =
        db.ref().child('suggested-places/$placeKey').get();
    placeData.then((value) {
      ref.set(value.value);
      db.ref().child('suggested-places/$placeKey').remove();
    });

    Future<DataSnapshot> scheduleData =
        db.ref().child('schedule/$placeKey-SUGGESTION').get();
    scheduleData.then((value) {
      schedule.set(value.value);
      db.ref().child('schedule/$placeKey-SUGGESTION').remove();
    });

    Future<DataSnapshot> tagData =
        db.ref().child('tags/$placeKey-SUGGESTION').get();
    tagData.then((value) {
      tags.set(value.value);
      db.ref().child('tags/$placeKey-SUGGESTION').remove();
    });

    await Future.wait([placeData, scheduleData, tagData]);
  }

  Future<void> declinePlace() async {
    if (isUsed) return;
    isUsed = true;

    await db.ref().child('suggested-places/$placeKey').remove();
    await db.ref().child('schedule/$placeKey-SUGGESTION').remove();
    await db.ref().child('tags/$placeKey-SUGGESTION').remove();
  }
}
