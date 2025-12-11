import 'package:flutter_tts/flutter_tts.dart';

class Speak {
  static final FlutterTts _tts = FlutterTts();

  /// Call this before using speak() anywhere (optional, but recommended)
  static Future<void> init() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
  }

  /// Speak any text
  static Future<void> say(String msg) async {
    await _tts.speak(msg);
  }
}
