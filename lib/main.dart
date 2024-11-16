import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myplaces/pages/permission_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Places',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: PermissionPage(),
    );
  }
}
