import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class Schedule {
  Schedule({required this.starthour, required this.endhour, required this.id});

  final String starthour;
  final String endhour;
  final int id;

  static List<Schedule> fromRTDB(dynamic data) {
    List<Schedule> schedule = <Schedule>[];
    if (data == null) return schedule;
    Map<dynamic, dynamic> rvalues = data as Map<dynamic, dynamic>;
    rvalues.forEach((key, value) {
      schedule.add(Schedule(
          starthour: value["starthour"],
          endhour: value["endhour"],
          id: value["id"]));
    });
    schedule.sort((a, b) => a.id.compareTo(b.id));
    return schedule;
  }
}

class ScheduleModel extends ChangeNotifier {
  ScheduleModel(this.key, this.db) {
    _listenToPlaceSchedules();
  }

  List<Schedule> _schedule = [];
  final DatabaseReference db;

  List<Schedule> get schedule => _schedule;

  late StreamSubscription<DatabaseEvent> _placeStream;
  final String key;

  void _listenToPlaceSchedules() {
    _placeStream = db.child('schedule/$key').onValue.listen((event) {
      _schedule = Schedule.fromRTDB(event.snapshot.value);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _placeStream.cancel();
    super.dispose();
  }
}
