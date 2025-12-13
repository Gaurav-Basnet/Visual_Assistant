import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visual_assistant/data/speak.dart';

class Obdetection extends StatefulWidget {
  const Obdetection({super.key});

  @override
  State<Obdetection> createState() => _ObdetectionState();
}

class _ObdetectionState extends State<Obdetection> {
  late ObjectDetector objectDetector;
  bool _isProcessing = false;
  List<String> detectedLabels = [];

  @override
  void initState() {
    super.initState();
    Speak.init();
    Speak.say("Object Detection Opened");

    // Initialize ML Kit Object Detector
    objectDetector = ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.single,
        classifyObjects: true,
        multipleObjects: true,
      ),
    );

    // Start detection on asset image
    _processAssetImage('assets/images/chair.jpg');
  }

  /// Copy asset to temporary file so ML Kit can read it
  Future<String> _copyAssetToFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final fileName = assetPath.split('/').last;
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  /// Process the image and update UI with detected objects
  Future<void> _processAssetImage(String assetPath) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final filePath = await _copyAssetToFile(assetPath);
      final inputImage = InputImage.fromFilePath(filePath);

      final objects = await objectDetector.processImage(inputImage);

      if (objects.isEmpty) {
        detectedLabels = ['No objects detected'];
        Speak.say("No objects detected");
      } else {
        // Extract unique labels
        detectedLabels = objects
            .where((o) => o.labels.isNotEmpty)
            .map((o) => o.labels.first.text)
            .toSet()
            .toList();

        if (detectedLabels.isNotEmpty) {
          Speak.say("Detected ${detectedLabels.join(', ')}");
        }
      }

      setState(() {});
    } catch (e) {
      detectedLabels = ['Detection failed'];
      print('Error detecting objects: $e');
      setState(() {});
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    objectDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Object Detection"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Center(
            child: Image.asset('assets/images/chair.jpg', fit: BoxFit.contain),
          ),
          if (detectedLabels.isNotEmpty)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: detectedLabels
                      .map(
                        (label) => Text(
                          label,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
