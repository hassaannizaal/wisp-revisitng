import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playLogoSound() async {
    try {
      // signature zen chime for WISP.ai appearance
      await _player.play(AssetSource('sounds/startsound_vGPe9df7.wav'));
    } catch (e) {
      if (kDebugMode) {
        if (e.toString().contains('NotAllowedError')) {
          print('AudioService (Web): Sound blocked by browser. Interaction required before audio plays.');
        } else {
          print('AudioService: Playback failed ($e)');
          print('Please ensure assets/sounds/startsound_vGPe9df7.wav exists.');
        }
      }
    }
  }

  void dispose() {
    _player.dispose();
  }
}
