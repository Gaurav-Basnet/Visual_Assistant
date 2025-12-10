import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:visual_assistant/widgetstree.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // get all cameras
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Widgetstree(), // your first screen
    );
  }
}
