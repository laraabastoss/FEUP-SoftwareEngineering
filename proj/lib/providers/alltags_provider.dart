import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class AllTag {
  AllTag({required this.name});

  final String name;

  static List<AllTag> fromRTDB(Map<dynamic, dynamic>? data) {
    List<AllTag> tags = <AllTag>[];
    if (data == null) return tags;
    data.forEach((key, value) {
      tags.add(AllTag(name: value["name"]));
    });
    return tags;
  }
}

class AllTagModel extends ChangeNotifier {
  AllTagModel(this.db) {
    _listenToPlaceSchedules();
  }

  final List<AllTag> _tags = [];
  final DatabaseReference db;
  late StreamSubscription<DatabaseEvent> _placeStream;

  List<AllTag> get tags => _tags;

  void _listenToPlaceSchedules() {
    _placeStream = db.child('all-tags').onValue.listen((event) {
      _tags.clear();
      _tags.addAll(
          AllTag.fromRTDB(event.snapshot.value as Map<dynamic, dynamic>?));
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _placeStream.cancel();
    super.dispose();
  }
}
