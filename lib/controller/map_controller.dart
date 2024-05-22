import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController with ChangeNotifier {
  final List<LatLng> _points = [];
  Set<Polyline> polylines = {};

  void addPolyline(Position position) {
    _points.add(position.toLatLng());
    polylines.add(
      Polyline(
        polylineId: const PolylineId("poly"),
        width: 5,
        color: Colors.amber,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        points: _points,
      ),
    );
    notifyListeners();
  }

  void clear() {
    _points.clear();
    polylines.clear();
    notifyListeners();
  }
}

extension ToLatLng on Position {
  LatLng toLatLng() => LatLng(latitude, longitude);
}
