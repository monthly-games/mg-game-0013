import 'package:flame_audio/flame_audio.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/assets/asset_types.dart';
import 'package:flutter/foundation.dart';

class AudioManagerImpl extends AudioManager {
  final bool _isMusicOn = true;
  final bool _isSfxOn = true;

  @override
  Future<void> initialize({List<AudioAssetMeta>? criticalSounds}) async {
    // Preload common SFX if they existed
    // await FlameAudio.audioCache.loadAll(['hit.wav', 'crit.wav']);
  }

  @override
  void playBgm(String fileName, {double volume = 0.5}) {
    if (!_isMusicOn) return;
    try {
      if (!FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.play(fileName, volume: volume);
      }
    } catch (e) {
      debugPrint("Error playing BGM $fileName: $e");
    }
  }

  @override
  Future<void> playSfx(String fileName, {double volume = 1.0, double pitch = 1.0}) async {
    if (!_isSfxOn) return;
    try {
      await FlameAudio.play(fileName, volume: volume);
    } catch (e) {
      debugPrint("Error playing SFX $fileName: $e");
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
