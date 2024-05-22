import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxometr/home/map/map_page.dart';
import 'package:taxometr/home/taxometer/taxomater_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    Geolocator.requestPermission().then((value) async {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        Geolocator.openLocationSettings();
      }
    }).onError((error, stackTrace) {
      log(error.toString());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TaxometerPage(),
                ),
              ),
              child: const Text("Taxometer"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapPage(),
                ),
              ),
              child: const Text("Map"),
            ),
          ],
        ),
      ),
    );
  }
}
