import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myplaces/pages/home_page.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionPage extends StatefulWidget {
  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  checkPermission(PermissionStatus status, BuildContext context) {
    switch (status) {
      case PermissionStatus.granted:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
        break;
      case PermissionStatus.restricted:
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.limited:
        openAppSettings();
        break;
      default: // PermissionStatus.undetermined
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/location.svg',
              height: 140,
            ),
            SizedBox(height: 40),
            Text(
              'Permitir Ubicación',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xff202644),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Para poder utilizar todas las funcioes de la aplicación, necesitamos tu gps',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xff202644).withOpacity(0.7),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffFFD15C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                PermissionStatus status = await Permission.location.request();
                checkPermission(status, context);
              },
              child: Text('Activar GPS'),
            )
          ],
        ),
      ),
    );
  }
}
