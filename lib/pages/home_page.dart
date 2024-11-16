import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<CameraPosition> initCurretLocation() async {
    Position currentPosition = await Geolocator.getCurrentPosition();
    return CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Places'),
      ),
      body: FutureBuilder(
          future: initCurretLocation(),
          builder: (BuildContext context, AsyncSnapshot snap) {
            if (snap.hasData) {
              return GoogleMap(
                initialCameraPosition: snap.data,
                myLocationEnabled: true,
                //myLocationButtonEnabled: true,
              );
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
