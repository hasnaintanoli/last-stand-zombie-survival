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
    _playSound('pistol_shoot.wav', fallback: 'shoot.wav');
  }

  void playShotgunShoot() {
    _playSound('shotgun_shoot.wav', fallback: 'shoot.wav');
  }

  void playRifleShoot() {
    _playSound('rifle_shoot.wav', fallback: 'shoot.wav');
  }

  void playShoot() {
    _playSound('shoot.wav');
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

  void _playSound(String file, {String? fallback}) {
    if (!LocalStorage.getSoundEnabled()) return;
    try {
      FlameAudio.play(file);
    } catch (_) {
      if (fallback != null) {
        try {
          FlameAudio.play(fallback);
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
