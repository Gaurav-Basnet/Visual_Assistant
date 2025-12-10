import 'package:flutter/material.dart';

class Obdetection extends StatelessWidget {
  const Obdetection({super.key});

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
}
