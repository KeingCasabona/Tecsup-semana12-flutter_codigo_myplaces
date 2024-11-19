import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myplaces/utils/map_style.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _positions = [];
  Position? lastPosition;

  late GoogleMapController googleMapController;

  @override
  void initState() {
    super.initState();
    currentPosition();
  }

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

  Future<Uint8List> imageToBytes(
    String path,
    //VALORES POR DEFECTO:
    {
    bool fromNetwork = false,
    int width = 100,
  }) async {
    late Uint8List bytes;

    if (fromNetwork) {
      File file = await DefaultCacheManager().getSingleFile(path);
      bytes = await file.readAsBytes();
    } else {
      ByteData byteData = await rootBundle.load(path);
      bytes = byteData.buffer.asUint8List();
    }
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    ui.FrameInfo frame = await codec.getNextFrame();

    ByteData? myByteData =
        await frame.image.toByteData(format: ui.ImageByteFormat.png);

    return myByteData!.buffer.asUint8List();
  }

  currentPosition() async {
    BitmapDescriptor positionIcon = BitmapDescriptor.fromBytes(await imageToBytes(
        'https://w7.pngwing.com/pngs/486/496/png-transparent-top-view-plan-view-top-view-plan-view-overlook.png',
        fromNetwork: true,
        width: 150));
    Polyline myPolyline = Polyline(
      polylineId: PolylineId('my_route'),
      color: Colors.pinkAccent,
      width: 7,
      points: _positions,
    );

    _polylines.add(myPolyline);
    Geolocator.getPositionStream().listen((Position position) {
      LatLng latLng = LatLng(position.latitude, position.longitude);
      _positions.add(latLng);

      //LA CAMARA SE MUEVE A LA POSICION ACTUAL:
      CameraUpdate cameraUpdate = CameraUpdate.newLatLng(latLng);
      googleMapController.animateCamera(cameraUpdate);

      double rotation = 0;
      if (lastPosition != null) {
        rotation = Geolocator.bearingBetween(
          lastPosition!.latitude,
          lastPosition!.longitude,
          latLng.latitude,
          latLng.longitude,
        );
      }

      Marker positionMarker = Marker(
        markerId: MarkerId('positionMarker'),
        position: latLng,
        icon: positionIcon,
        rotation: rotation,
      );
      _markers.add(positionMarker);
      lastPosition = position;

      setState(() {});
    });
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
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    onMapCreated: (GoogleMapController controller) {
                      googleMapController = controller;
                      googleMapController.setMapStyle(jsonEncode(mapStyle));
                    },
                    onTap: (LatLng position) async {
                      MarkerId myMarkerId =
                          MarkerId(_markers.length.toString());
                      Marker myMarker = Marker(
                        markerId: myMarkerId,

                        position: position,
                        // icon: BitmapDescriptor.defaultMarkerWithHue(
                        //     BitmapDescriptor.hueGreen),
                        // icon: await BitmapDescriptor.fromAssetImage(
                        //     ImageConfiguration(), 'assets/images/marker2.png'),

                        icon: BitmapDescriptor.fromBytes(
                          await imageToBytes(
                              'https://w7.pngwing.com/pngs/708/311/png-transparent-icon-logo-twitter-logo-twitter-logo-blue-social-media-area-thumbnail.png',
                              width: 200,
                              fromNetwork: true),
                        ),
                        //ARRASTRAR EL MARCADOR:
                        draggable: true,
                        onDrag: (LatLng newPosition) {},
                        onTap: () {
                          print('Holaaaaa');
                        },
                      );
                      _markers.add(myMarker);
                      setState(() {});
                    },
                    markers: _markers,
                    polylines: _polylines,
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
