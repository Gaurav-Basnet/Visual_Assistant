import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'vision_camera.dart'; // import the module you created

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // get all cameras
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VisionCamera(cameras: cameras), // pass cameras to your widget
    );
  }
}
