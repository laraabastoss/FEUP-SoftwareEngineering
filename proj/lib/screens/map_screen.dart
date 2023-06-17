import 'package:brain_box/screens/place_suggesting_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

import '../providers/latlong_provider.dart';
import '../providers/location_provider.dart';
import 'location_screen.dart';

class MapMenu extends StatefulWidget {
  MapMenu({super.key});

  @override
  State<StatefulWidget> createState() => MapMenuState();
}

class MapMenuState extends State<MapMenu> {
  final double _initialZoom = 15;
  final Future<LocationData?> _future = LatLongProvider.getLocation(Location());
  List<Place> _oldPlaces = <Place>[];
  final MapTileLayerController _controller = MapTileLayerController();
  final MapZoomPanBehavior _mapZoomPanBehavior = MapZoomPanBehavior();
  int _index = -1;
  onTapped(index) {
    setState(
      () {
        _index = index;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Consumer<LocationModel>(
      key: Key('map_screen'),
      builder: (context, model, child) {
        List<Place> places = model.places;
        int n = places.length;
        if (_oldPlaces.isEmpty) _oldPlaces = places;
        if (places.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.08),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(width: width * 0.05),
                  FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Colors.cyan,
                    onPressed: () {
                      if (_controller.markersCount != places.length) {
                        _oldPlaces = places;
                        _controller.clearMarkers();
                        for (int i = 0; i < places.length; i++) {
                          _controller.insertMarker(i);
                        }
                      }
                      setState(
                        () {
                          _index = -1;
                        },
                      );
                    },
                    child: const Icon(
                      Icons.refresh,
                    ),
                  ),
                  if (!(FirebaseAuth.instance.currentUser?.isAnonymous ??
                      false))
                    FloatingActionButton(
                      heroTag: null,
                      backgroundColor: Colors.cyan,
                      onPressed: () => {
                        Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                            builder: (BuildContext context) {
                              return const PlaceSuggestingScreen();
                            },
                          ),
                        ),
                      },
                      child: const Icon(Icons.add),
                    )
                ],
              ),
              SizedBox(height: height * 0.65),
              if (_index != -1)
                Expanded(
                  child: SizedBox(
                    width: width * 0.9,
                    height: height * 0.063,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white70.withOpacity(0.78),
                      ),
                      child: TextButton(
                        onPressed: () => {
                          Navigator.of(context).push(
                            CupertinoPageRoute<void>(
                              builder: (BuildContext context) {
                                return LocationScreen(
                                    place: _oldPlaces[_index]);
                              },
                            ),
                          ),
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.pin_drop_rounded,
                                  color: Colors.cyan,
                                  size: 50,
                                ),
                                Container(width: width * 0.04),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _oldPlaces[_index].name,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 3,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Lato',
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      _oldPlaces[_index].city,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 3,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Lato',
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: Center(
            child: FutureBuilder<LocationData?>(
                future: _future,
                builder: (BuildContext context,
                    AsyncSnapshot<LocationData?> snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SfMaps(
                    layers: [
                      MapTileLayer(
                        controller: _controller,
                        initialZoomLevel: _initialZoom.toInt(),
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        initialFocalLatLng: MapLatLng(
                            snapshot.data?.latitude ?? 0,
                            snapshot.data?.longitude ?? 0),
                        initialMarkersCount: n,
                        markerBuilder: (BuildContext context, int index) {
                          print("I AM ADDING A MARKER");
                          return MapMarker(
                              latitude: _oldPlaces[index].latitude,
                              longitude: _oldPlaces[index].longitude,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.cyan,
                                size: 35,
                              ));
                        },
                        markerTooltipBuilder:
                            (BuildContext context, int index) {
                          onTapped(index);
                          return Container(
                            width: 150,
                            padding: const EdgeInsets.all(10),
                            color: Colors.cyan,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  children: [
                                    Center(
                                      child: Text(
                                        _oldPlaces[index].city,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .fontSize),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.tour,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.white,
                                  height: 10,
                                  thickness: 1.2,
                                ),
                                Text(
                                  _oldPlaces[index].name,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .fontSize),
                                ),
                              ],
                            ),
                          );
                        },
                        tooltipSettings: const MapTooltipSettings(
                            color: Color.fromARGB(255, 54, 136, 244),
                            strokeColor: Colors.black,
                            strokeWidth: 1.5),
                        zoomPanBehavior: _mapZoomPanBehavior,
                      ),
                    ],
                  );
                }),
          ),
        );
      },
    );
  }
}
