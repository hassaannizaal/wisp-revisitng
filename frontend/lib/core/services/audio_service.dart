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
      // Renamed for better web resolution/compatibility
      await _player.play(AssetSource('sounds/start_sound.wav'));
    } catch (e) {
      if (kDebugMode) {
        final errorStr = e.toString();
        if (errorStr.contains('NotAllowedError')) {
          print('AudioService (Web): Sound blocked by browser. Interaction required before audio plays.');
        } else if (errorStr.contains('Code: 4') || errorStr.contains('Format error')) {
          print('AudioService (Web): Format error (Code 4). This usually means the browser does not support the WAV encoding or the file is corrupted.');
        } else {
          print('AudioService: Playback failed ($e)');
        }
      }
    }
  }

  void dispose() {
    _player.dispose();
  }
}
