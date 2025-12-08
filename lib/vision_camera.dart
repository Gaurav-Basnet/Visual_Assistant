import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class VisionCamera extends StatefulWidget {
  final List<CameraDescription> cameras;
  const VisionCamera({required this.cameras, Key? key}) : super(key: key);

  @override
  _VisionCameraState createState() => _VisionCameraState();
}

class _VisionCameraState extends State<VisionCamera> {
  CameraController? controller;
  bool isStreaming = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    if (widget.cameras.isEmpty) {
      print("No cameras found!");
      return;
    }

    // Initialize the first available camera
    controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.low, // low for faster processing
      enableAudio: false,
    );

    await controller!.initialize();

    // Start streaming frames
    controller!.startImageStream((CameraImage image) {
      if (!isStreaming) {
        isStreaming = true;

        // TODO: Send 'image' to your detection + distance + TTS module
        print("New frame received: ${image.width}x${image.height}");

        // After processing, reset streaming flag
        isStreaming = false;
      }
    });

    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(body: CameraPreview(controller!));
  }
}
