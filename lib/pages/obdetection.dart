import 'package:flutter/material.dart';
import 'package:visual_assistant/data/speak.dart';

class Obdetection extends StatefulWidget {
  const Obdetection({super.key});

  @override
  State<Obdetection> createState() => _ObdetectionState();
}

class _ObdetectionState extends State<Obdetection> {
  @override
  void initState() {
    Speak.init();
    Speak.say("Object Detection Opened");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        title: const Text(
          "Object Detection",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // Placeholder until we add camera view
      body: const Center(
        child: Text(
          "Camera loading...",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ),
    );
  }

  void initautoSpeeK() {}
}
