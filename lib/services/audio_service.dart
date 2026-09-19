import 'package:flame_audio/flame_audio.dart';
import 'local_storage.dart';

class AudioService {
  bool _initialized = false;

  Future<void> init() async {
    try {
      FlameAudio.bgm.initialize();
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  void playPistolShoot() {
    _playSound('pistol_shot.wav', fallback: 'pistol_shoot.wav');
  }

  void playShotgunShoot() {
    _playSound('shotgun_shot.wav', fallback: 'shotgun_shoot.wav');
  }

  void playRifleShoot() {
    _playSound('rifle_shot.wav', fallback: 'rifle_shoot.wav');
  }

  void playShoot() {
    _playSound('pistol_shot.wav', fallback: 'shoot.wav');
  }

  void playReload() {
    _playSound('reload.wav');
  }

  void playZombieAttack() {
    _playSound('zombie_attack.wav');
  }

  void playZombieDeath() {
    _playSound('zombie_death.wav');
  }

  void playPickup() {
    _playSound('pickup.wav');
  }

  void playLevelUp() {
    _playSound('levelup.wav');
  }

  void playGameOver() {
    _playSound('gameover.wav');
  }

  AudioPlayer? _footstepPlayer;
  bool _isFootstepPlaying = false;

  void startFootstep({double volume = 0.55}) {
    if (!LocalStorage.getSoundEnabled() || _isFootstepPlaying) return;
    _isFootstepPlaying = true;
    _startFootstepAsync(volume);
  }

  Future<void> _startFootstepAsync(double volume) async {
    try {
      if (_footstepPlayer != null) {
        await _footstepPlayer!.resume();
      } else {
        _footstepPlayer = await FlameAudio.loop(
          'Slow_footsteps.wav',
          volume: volume,
        );
      }
    } catch (_) {
      try {
        _footstepPlayer = await FlameAudio.loopLongAudio(
          'Slow_footsteps.wav',
          volume: volume,
        );
      } catch (_) {
        _isFootstepPlaying = false;
      }
    }
  }

  void stopFootstep() {
    if (!_isFootstepPlaying && _footstepPlayer == null) return;
    _isFootstepPlaying = false;
    try {
      _footstepPlayer?.pause();
    } catch (_) {}
  }

  void _playSound(String file, {String? fallback, double volume = 1.0}) {
    if (!LocalStorage.getSoundEnabled()) return;
    try {
      FlameAudio.play(file, volume: volume);
    } catch (_) {
      if (fallback != null) {
        try {
          FlameAudio.play(fallback, volume: volume);
        } catch (_) {}
      }
    }
  }

  void startBgm() {
    if (!LocalStorage.getMusicEnabled() || !_initialized) return;
    try {
      FlameAudio.bgm.play('bgm.mp3', volume: 0.45);
    } catch (_) {
      try {
        FlameAudio.bgm.play('bgm.wav', volume: 0.45);
      } catch (_) {}
    }
  }

  void stopBgm() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }
}
