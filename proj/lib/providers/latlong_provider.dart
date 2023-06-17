

import 'package:location/location.dart';

class LatLongProvider {
  static Future<LocationData?> getLocation(Location location) async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return Future.value(LocationData.fromMap({'latitude': 41.0, 'longitude': -8.0}));
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return Future.value(LocationData.fromMap({'latitude': 41.0, 'longitude': -8.0}));
      }
    }

    return location.getLocation();
  }
}