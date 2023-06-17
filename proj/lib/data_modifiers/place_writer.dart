import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../providers/tags_provider.dart';

class PlaceWriter {
  PlaceWriter(
      {required this.name,
      required this.city,
      required this.latitude,
      required this.longitude,
      required this.db});

  final String name;
  final String city;
  final double latitude;
  final double longitude;
  late final String key;
  final FirebaseDatabase db;

  void createPlace() {
    DatabaseReference ref = db.ref().child('suggested-places').push();
    key = ref.key!;

    Map<dynamic, dynamic> place = {
      'lat': latitude,
      'long': longitude,
      'name': name,
      'city': city,
      'comments': 0,
      'rate': 0,
      'tags': 'none'
    };
    ref.set(place);
  }

  void addSchedule(List<TimeOfDay> schedule) {
    DatabaseReference ref = db.ref().child('schedule/$key-SUGGESTION');

    final List<String> days = List.from([
      "amonday",
      "btuesday",
      "cwednesday",
      "dthursday",
      "efriday",
      "fsaturday",
      "gsunday"
    ]);

    Map<dynamic, dynamic> scheduleMap = {};
    for (int i = 0; i < days.length; i++) {
      scheduleMap[days[i]] = {
        "endhour": "${schedule[2 * i + 1].hour}h${schedule[2 * i + 1].minute}",
        "id": i + 1,
        "starthour": "${schedule[2 * i].hour}h${schedule[2 * i].minute}"
      };
    }

    ref.set(scheduleMap);
  }

  void addTags(List<Tag> tags) {
    DatabaseReference ref = db.ref().child('tags/$key-SUGGESTION');
    DatabaseReference placeRef = db.ref().child('suggested-places/$key/tags');
    String tagString = tags.join(',');

    Map<dynamic, dynamic> tagMaps = {};
    for (int i = 0; i < tags.length; i++) {
      tagMaps["tag$i"] = {"name": tags[i].name};
    }

    ref.set(tagMaps);
    placeRef.set(tagString);
  }
}
