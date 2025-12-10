import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:visual_assistant/pages/obdetection.dart';

class Widgetstree extends StatefulWidget {
  const Widgetstree({super.key});

  @override
  State<Widgetstree> createState() => _WidgetstreeState();
}

class _WidgetstreeState extends State<Widgetstree> {
  final SpeechToText _speechToText = SpeechToText();
  Timer? _restartTimer;
  int _utteranceCount = 0;
  DateTime? _lastUtteranceTime;
  bool _isListening = false;

  // List of options that can be spoken
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
      body: Column(
        children: [
          // Listening status indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: _isListening
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mic,
                  color: _isListening ? Colors.green : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _isListening ? 'Listening...' : 'Not Listening',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isListening ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Instructions
          Container(
            padding: const EdgeInsets.all(20),
            child: const Column(
              children: [
                SizedBox(height: 10),
                Text(
                  'Say "open home" to navigate to Home page',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Options List
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Icon(_getIconForOption(index), color: Colors.blue),
                    ),
                    title: Text(
                      options[index],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      _getSubtitleForOption(index),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () => _navigateToPage(index),
                  ),
                );
              },
            ),
          ),

          // Stats footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween),
          ),
        ],
      ),
    );
  }

  void _initSpeech() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        print("Status: $status at ${DateTime.now()}");

        setState(() {
          _isListening = status == 'listening';
        });

        // Schedule restart if not listening anymore
        if (status == 'notListening' || status == 'done') {
          _scheduleRestart();
        }
      },
      onError: (error) {
        print("Error: $error at ${DateTime.now()}");
        setState(() {
          _isListening = false;
        });
        _scheduleRestart();
      },
    );

    if (available) {
      _startContinuousListening();
    } else {
      print("Speech not available, retrying in 10 seconds...");
      _scheduleRetry();
    }
  }

  void _startContinuousListening() {
    try {
      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
            _utteranceCount++;
            _lastUtteranceTime = DateTime.now();
            setState(() {});

            String timestamp = DateTime.now()
                .toString()
                .split(' ')[1]
                .substring(0, 8);
            String spokenWords = result.recognizedWords.toLowerCase().trim();

            print("[$timestamp] Utterance #$_utteranceCount: $spokenWords");

            // Check if spoken words match any option
            for (int i = 0; i < options.length; i++) {
              if (spokenWords.contains(options[i].toLowerCase())) {
                print("Match found! Navigating to: ${options[i]}");
                _navigateToPage(i);
                break; // Stop after first match
              }
            }

            // Reset restart timer when we get speech
            _restartTimer?.cancel();
          }
        },
        listenFor: const Duration(minutes: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: false,
        listenMode: ListenMode.confirmation,
        cancelOnError: false,
      );

      print("Started listening session at ${DateTime.now()}");
      setState(() {
        _isListening = true;
      });
    } catch (e) {
      print("Error starting listen: $e");
      setState(() {
        _isListening = false;
      });
      _scheduleRestart();
    }
  }

  void _navigateToPage(int index) {
    String option = options[index];

    // Show a snackbar for visual feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to: $option'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate to different pages based on option
    switch (option.toLowerCase()) {
      case 'open home':
        _navigateToObDetection();
        break;
      case 'go to settings':
        _navigateToSettingsPage();
        break;
      case 'show profile':
        _navigateToProfilePage();
        break;
      case 'view notifications':
        _navigateToNotificationsPage();
        break;
      case 'open dashboard':
        _navigateToDashboardPage();
        break;
      default:
        print("Unknown option: $option");
    }
  }

  // Navigation methods for each page
  void _navigateToObDetection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Obdetection()),
    );
  }

  void _navigateToSettingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Settings Page')),
          body: const Center(child: Text('Settings Page Content')),
        ),
      ),
    );
  }

  void _navigateToProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Profile Page')),
          body: const Center(child: Text('Profile Page Content')),
        ),
      ),
    );
  }

  void _navigateToNotificationsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Notifications Page')),
          body: const Center(child: Text('Notifications Page Content')),
        ),
      ),
    );
  }

  void _navigateToDashboardPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Dashboard Page')),
          body: const Center(child: Text('Dashboard Page Content')),
        ),
      ),
    );
  }

  // Helper methods for UI
  IconData _getIconForOption(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.settings;
      case 2:
        return Icons.person;
      case 3:
        return Icons.notifications;
      case 4:
        return Icons.dashboard;
      default:
        return Icons.arrow_forward;
    }
  }

  String _getSubtitleForOption(int index) {
    switch (index) {
      case 0:
        return 'Tap or say "open home"';
      case 1:
        return 'Tap or say "go to settings"';
      case 2:
        return 'Tap or say "show profile"';
      case 3:
        return 'Tap or say "view notifications"';
      case 4:
        return 'Tap or say "open dashboard"';
      default:
        return 'Tap or speak this command';
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _speechToText.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      _startContinuousListening();
    }
  }

  void _scheduleRestart() {
    _restartTimer?.cancel();
    _restartTimer = Timer(const Duration(seconds: 2), () {
      if (!_speechToText.isListening) {
        print("Restarting listening at ${DateTime.now()}");
        _startContinuousListening();
      }
    });
  }

  void _scheduleRetry() {
    _restartTimer?.cancel();
    _restartTimer = Timer(const Duration(seconds: 10), () {
      print("Retrying speech initialization at ${DateTime.now()}");
      _initSpeech();
    });
  }

  @override
  void dispose() {
    _restartTimer?.cancel();
    _speechToText.stop();
    _speechToText.cancel();
    super.dispose();
  }
}
