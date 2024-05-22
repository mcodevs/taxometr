import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxometr/controller/map_controller.dart';
import 'package:taxometr/controller/speed_controller.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MapController(),
      child: ChangeNotifierProvider(
        create: (context) => SpeedController(
          baseAmount: 4000,
          perDistance: 2000,
        ),
        child: const MapView(),
      ),
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late MapController mapController;
  @override
  void initState() {
    mapController = context.read<MapController>();
    context.read<SpeedController>().onPositionChanged = (position) {
      mapController.addPolyline(position);
      _controller.moveCamera(position);
    };

    super.initState();
  }

  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            heroTag: "a",
            child: Selector<SpeedController, bool>(
              builder: (context, value, child) {
                return Icon(value ? Icons.play_arrow : Icons.pause);
              },
              selector: (_, provider) => provider.isPaused,
            ),
            onPressed: () async {
              final controller = context.read<SpeedController>();
              if (controller.isPaused) {
                await controller.start();
              } else {
                controller.stop();
              }
            },
          ),
          CircleAvatar(
            radius: 40,
            child: Center(
              child: Selector<SpeedController, double>(
                builder: (context, value, child) {
                  return Text(
                    "$value so'm",
                    textAlign: TextAlign.center,
                  );
                },
                selector: (p0, p1) => p1.amount,
              ),
            ),
          ),
          FloatingActionButton(
            heroTag: "b",
            onPressed: () {
              context.read<SpeedController>().clear();
              context.read<MapController>().clear();
            },
            child: const Icon(Icons.clear),
          )
        ],
      ),
      body: Stack(
        children: [
          Consumer<MapController>(builder: (context, controller, child) {
            return GoogleMap(
              polylines: controller.polylines,
              initialCameraPosition: const CameraPosition(
                target: LatLng(41.273790, 69.202060),
              ),
              onMapCreated: _controller.complete,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            );
          }),
          Positioned(
            right: 10,
            top: 200,
            child: CircleAvatar(
              radius: 40,
              child: Center(
                child: Selector<SpeedController, int>(
                  builder: (context, value, child) {
                    return Text(
                      "$value\nkm/h",
                      textAlign: TextAlign.center,
                    );
                  },
                  selector: (p0, p1) => p1.speed,
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 200,
            child: CircleAvatar(
              radius: 40,
              child: Center(
                child: Selector<SpeedController, double>(
                  builder: (context, value, child) {
                    return Text(
                      "${(value / 1000).toStringAsFixed(2)}\nkm",
                      textAlign: TextAlign.center,
                    );
                  },
                  selector: (p0, p1) => p1.distance,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on Completer<GoogleMapController> {
  Future<void> moveCamera(Position position) async {
    final controller = await future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position.toLatLng(),
          zoom: 17,
          bearing: position.heading,
        ),
      ),
    );
  }
}
