import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:volume_controller/volume_controller.dart';

import 'package:visual_assistant/pages/obdetection.dart';

class Widgetstree extends StatefulWidget {
  const Widgetstree({super.key});

  @override
  State<Widgetstree> createState() => _WidgetstreeState();
}

class _WidgetstreeState extends State<Widgetstree> {
  final SpeechToText _speechToText = SpeechToText();
  Timer? _restartTimer;
  bool _isListening = false;

  // List of voice commands
  final List<String> options = [
    "open home",
    "go to settings",
    "show profile",
    "view notifications",
    "open dashboard",
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Navigation'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(options[index]),
              onTap: () => _navigateToPage(index),
            ),
          );
        },
      ),
    );
  }

  // -------------------------
  // Initialize speech system
  // -------------------------
  void _initSpeech() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        print("STATUS: $status");

        _isListening = status == "listening";

        if (status == "notListening" || status == "done") {
          _scheduleRestart();
        }
      },
      onError: (error) {
        print("ERROR: $error");
        _scheduleRestart();
      },
    );

    if (available) {
      _startListening();
    } else {
      print("Speech not available. Retrying...");
      _scheduleRetry();
    }
  }

  // -------------------------
  // Start listening
  // -------------------------
  void _startListening() {
    try {
      _speechToText.listen(
        onResult: (result) {
          String words = result.recognizedWords.toLowerCase().trim();

          if (result.finalResult && words.isNotEmpty) {
            print("USER SAID: $words");

            // Match voice commands
            for (int i = 0; i < options.length; i++) {
              if (words.contains(options[i])) {
                print("MATCH: ${options[i]}");
                _navigateToPage(i);
                break;
              }
            }
          }
        },
        partialResults: false,
        listenMode: ListenMode.confirmation,
        pauseFor: const Duration(minutes: 5),
        listenFor: const Duration(minutes: 30),
      );

      print("Started listening...");
    } catch (err) {
      print("FAILED TO START LISTENING: $err");
      _scheduleRestart();
    }
  }

  // -------------------------
  // Restart if stopped
  // -------------------------
  void _scheduleRestart() {
    _restartTimer?.cancel();
    _restartTimer = Timer(const Duration(seconds: 2), () {
      if (!_speechToText.isListening) {
        print("Restarting listening...");
        _startListening();
      }
    });
  }

  void _scheduleRetry() {
    _restartTimer?.cancel();
    _restartTimer = Timer(const Duration(seconds: 10), () {
      print("Retrying initialization...");
      _initSpeech();
    });
  }

  // -------------------------
  // Navigation Handlers
  // -------------------------
  void _navigateToPage(int index) {
    _speechToText.stop();
    _restartTimer?.cancel();

    switch (options[index]) {
      case "open home":
        _navigateToObDetection();
        break;

      case "go to settings":
        _simplePage("Settings Page");
        break;

      case "show profile":
        _simplePage("Profile Page");
        break;

      case "view notifications":
        _simplePage("Notifications Page");
        break;

      case "open dashboard":
        _simplePage("Dashboard Page");
        break;
    }
  }

  void _navigateToObDetection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Obdetection()),
    );
  }

  void _simplePage(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(child: Text(title)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _restartTimer?.cancel();
    _speechToText.stop();
    _speechToText.cancel();
    super.dispose();
  }
}
