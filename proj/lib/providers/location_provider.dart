import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';


class Place {
 Place(this.city, this.name, this.latitude, this.longitude, this.rate, this.tags, this.comments, this.key);


  final String city;
  final String name;
  final double latitude;
  final double longitude;
  late final int comments;
  final String key;
  final String tags;
  final double rate;


  static List<Place> fromRTDB(dynamic data) {
    List<Place> places = <Place>[];
    if (data == null) return places;
    Map<dynamic, dynamic> values = (data ?? {}) as Map<dynamic, dynamic>;
    values.forEach((key, value) {
      places.add(Place(
          value["city"],
          value["name"],
          value["lat"],
          value["long"],
          value['rate'].toDouble(),
          value["tags"],
          value["comments"], key));
    });
    places.sort((a, b) => a.comments.compareTo(b.comments));
    places=places.reversed.toList();
    return places;
  }
}

class SuggestedPlace extends Place {
  SuggestedPlace(
      String city,
      String name,
      double latitude,
      double longitude,
      int comments,
      String key,
      ) : super(city, name, latitude, longitude, 0.0, "", comments, key);

  static List<SuggestedPlace> fromRTDB(dynamic data) {
    List<SuggestedPlace> suggestedPlaces = <SuggestedPlace>[];
    Map<dynamic, dynamic> values = (data ?? {}) as Map<dynamic, dynamic>;
    values.forEach((key, value) {
      suggestedPlaces.add(SuggestedPlace(
        value["city"],
        value["name"],
        value["lat"],
        value["long"],
        value["comments"],
        key,
      ));
    });
    suggestedPlaces.sort((a, b) => a.comments.compareTo(b.comments));
    suggestedPlaces = suggestedPlaces.reversed.toList();
    return suggestedPlaces;
  }
}

class LocationModel extends ChangeNotifier {
  List<Place> _places = [];
  List<Place> _suggestedPlaces = [];
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  List<Place> get places => _places;
  List<Place> get suggestedPlaces => _suggestedPlaces;

  late StreamSubscription<DatabaseEvent> _placeStream;
  late StreamSubscription<DatabaseEvent> _suggestedPlaceStream;

  LocationModel() {
    _listenToPlaces();
    _listenToSuggestedPlaces();
  }

  void _listenToPlaces() {
    _placeStream = _db.child('places').onValue.listen((event) {
      try {
        _places = Place.fromRTDB(event.snapshot.value);
        notifyListeners();
      } catch (error) {
        debugPrint('Error retrieving places: $error');
      }
    }, onError: (error) {
      debugPrint('Database error: $error');
    });
  }

  void _listenToSuggestedPlaces() {
    _suggestedPlaceStream = _db.child('suggested-places').onValue.listen((event) {
      try {
        _suggestedPlaces = SuggestedPlace.fromRTDB(event.snapshot.value);
        notifyListeners();
      } catch (error) {
        debugPrint('Error retrieving places: $error');
      }
    }, onError: (error) {
      debugPrint('Database error: $error');
    });
  }

  void stopListeningToPlaces() {
    _placeStream.cancel();
  }

  @override
  void dispose() {
    _placeStream.cancel();
    _suggestedPlaceStream.cancel();
    super.dispose();
  }
}

void incrementcomments(Place place){
    place.comments=place.comments+1;
}