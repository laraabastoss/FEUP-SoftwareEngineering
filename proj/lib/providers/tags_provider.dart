import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class Tag {
  Tag({required this.name});

  final String name;

  static List<Tag> fromRTDB(dynamic data) {
    List<Tag> tags = <Tag>[];
    if (data == null) return tags;
    Map<dynamic, dynamic> rvalues = data as Map<dynamic, dynamic>;
    rvalues.forEach((key, value) {
      tags.add(Tag(name: value["name"]));
    });
    return tags;
  }

  @override
  bool operator ==(Object other) {
    return (other is Tag) && name == other.name;
  }

  @override
  String toString() {
    return name;
  }

  @override
  int get hashCode => Object.hash(name, name);
}

class TagModel extends ChangeNotifier {
  TagModel(this.key) {
    _listenToPlaceSchedules();
  }

  List<Tag> _tags = [];
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  List<Tag> get tags => _tags;

  late StreamSubscription<DatabaseEvent> _placeStream;
  final String key;

  void _listenToPlaceSchedules() {
    _placeStream = _db.child('tags/$key').onValue.listen((event) {
      _tags = Tag.fromRTDB(event.snapshot.value);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _placeStream.cancel();
    super.dispose();
  }
}

class AllTagsModel extends ChangeNotifier {
  AllTagsModel() {
    _listenToTags();
  }

  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  late StreamSubscription<DatabaseEvent> _tagStream;
  List<Tag> _tags = [];

  List<Tag> get tags => _tags;

  void _listenToTags() {
    _tagStream = _db.child('all-tags').onValue.listen((event) {
      _tags = Tag.fromRTDB(event.snapshot.value);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _tagStream.cancel();
    super.dispose();
  }
}
