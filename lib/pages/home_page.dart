import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myplaces/utils/map_style.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController googleMapController;

  Future<CameraPosition> initCurretLocation() async {
    Position currentPosition = await Geolocator.getCurrentPosition();
    return CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 15);
  }

  Future<void> moveCamera() async {
    Position currentPosition = await Geolocator.getCurrentPosition();
    CameraUpdate cameraUpdate = CameraUpdate.newLatLng(
      LatLng(currentPosition.latitude, currentPosition.longitude),
    );
    googleMapController.animateCamera(cameraUpdate);
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
              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: snap.data,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    onMapCreated: (GoogleMapController controller) {
                      googleMapController = controller;
                      googleMapController.setMapStyle(jsonEncode(mapStyle));
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          moveCamera();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: Text(
                          'Mi ubicacion',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
