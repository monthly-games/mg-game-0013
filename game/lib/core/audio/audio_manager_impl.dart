import 'package:flame_audio/flame_audio.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';

class AudioManagerImpl extends AudioManager {
  bool _isMusicOn = true;
  bool _isSfxOn = true;

  @override
  Future<void> initialize() async {
    // Preload common SFX if they existed
    // await FlameAudio.audioCache.loadAll(['hit.wav', 'crit.wav']);
  }

  @override
  void playBgm(String file, {double volume = 0.5}) {
    if (!_isMusicOn) return;
    try {
      if (!FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.play(file, volume: volume);
      }
    } catch (e) {
      print("Error playing BGM $file: $e");
    }
  }

  @override
  void playSfx(String file, {double volume = 1.0, double pitch = 1.0}) {
    if (!_isSfxOn) return;
    try {
      FlameAudio.play(file, volume: volume);
    } catch (e) {
      print("Error playing SFX $file: $e");
    }
  }

  @override
  void stopBgm() {
    FlameAudio.bgm.stop();
  }

  @override
  void pauseBgm() {
    FlameAudio.bgm.pause();
  }

  @override
  void resumeBgm() {
    if (_isMusicOn) {
      FlameAudio.bgm.resume();
    }
  }
}
