import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SpeedController with ChangeNotifier {
  static final locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 5,
    forceLocationManager: true,
    intervalDuration: const Duration(seconds: 1),
  );

  StreamSubscription? _sub;
  Timer? _timer;

  Position? lastPosition;

  double distance = 0;
  int speed = 0;
  int seconds = 0;

  double baseAmount;
  double perDistance;

  void Function(Position position)? onPositionChanged;

  SpeedController({
    required this.baseAmount,
    required this.perDistance,
  });

  double get amount =>
      baseAmount +
      (double.parse((distance / 1000).toStringAsFixed(2)) * perDistance);

  bool get isPaused => _sub?.isPaused ?? true;

  Future<void> start() async {
    final value = await Geolocator.checkPermission();
    if (!value.isGranted) return;
    _timer ??= Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        seconds++;
        notifyListeners();
      },
    );
    if (_sub != null) {
      _sub?.resume();
      notifyListeners();
      print("bu har doim ishliydi");
      return;
    }
    print("1 marta ishliydi");
    _sub = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((event) {
      onPositionChanged?.call(event);
      speed = (event.speed * 3.6).toInt();
      if (lastPosition != null) {
        final dis = Geolocator.distanceBetween(
          lastPosition!.latitude,
          lastPosition!.longitude,
          event.latitude,
          event.longitude,
        );
        distance += dis;
      }
      lastPosition = event;
      notifyListeners();
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void clear() {
    distance = 0;
    lastPosition = null;
    _timer?.cancel();
    _timer = null;
    _sub?.pause();
    _sub = null;
    seconds = 0;
    notifyListeners();
  }

  void stop() {
    _sub?.pause();
    notifyListeners();
  }
}

extension on LocationPermission {
  bool get isGranted =>
      this == LocationPermission.always ||
      this == LocationPermission.whileInUse;
}
