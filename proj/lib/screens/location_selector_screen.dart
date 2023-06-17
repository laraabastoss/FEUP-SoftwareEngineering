import 'package:brain_box/providers/latlong_provider.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class LocationSelectorScreen extends StatelessWidget {
  LocationSelectorScreen({super.key, required this.callback});

  late MapLatLng _markerPosition;
  late _CustomZoomPanBehavior _mapZoomPanBehavior;
  final MapTileLayerController _controller = MapTileLayerController();
  final _future = LatLongProvider.getLocation(Location());

  final void Function(double, double) callback;

  void updateMarkerChange(Offset position) {
    _markerPosition = _controller.pixelToLatLng(position);
    callback(_markerPosition.latitude, _markerPosition.longitude);

    if (_controller.markersCount > 0) {
      _controller.clearMarkers();
    }
    _controller.insertMarker(0);
  }

  @override
  Widget build(BuildContext context) {
    _mapZoomPanBehavior = _CustomZoomPanBehavior()..onTap = updateMarkerChange;
    return Scaffold(
      body: Center(
        child: FutureBuilder(
            future: _future,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              return SfMaps(
                layers: [
                  MapTileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    zoomPanBehavior: _mapZoomPanBehavior,
                    controller: _controller,
                    initialZoomLevel: 15,
                    initialFocalLatLng: MapLatLng(snapshot.data?.latitude ?? 0,
                        snapshot.data?.longitude ?? 0),
                    markerBuilder: (BuildContext context, int index) {
                      return MapMarker(
                          latitude: _markerPosition.latitude,
                          longitude: _markerPosition.longitude,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.cyan,
                            size: 35,
                          ));
                    },
                  ),
                ],
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan,
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

class _CustomZoomPanBehavior extends MapZoomPanBehavior {
  _CustomZoomPanBehavior();
  late final void Function(Offset) onTap;

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent) {
      onTap(event.localPosition);
    }
    super.handleEvent(event);
  }
}
