import 'package:flame_audio/flame_audio.dart';
import 'local_storage.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();
  factory AudioService() => instance;
  AudioService._internal();

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
  bool _footstepDesired = false;
  bool _isFootstepLoading = false;

  void startFootstep({double volume = 0.55}) {
    if (!LocalStorage.getSoundEnabled()) {
      stopFootstep();
      return;
    }
    if (_isFootstepPlaying || _isFootstepLoading) return;
    _footstepDesired = true;
    _isFootstepPlaying = true;
    _startFootstepAsync(volume);
  }

  Future<void> _startFootstepAsync(double volume) async {
    if (!_footstepDesired || !LocalStorage.getSoundEnabled()) {
      _isFootstepPlaying = false;
      return;
    }
    _isFootstepLoading = true;
    try {
      if (_footstepPlayer != null) {
        if (_footstepDesired && LocalStorage.getSoundEnabled()) {
          await _footstepPlayer!.resume();
        } else {
          await _footstepPlayer!.pause();
          await _footstepPlayer!.stop();
        }
        _isFootstepLoading = false;
        return;
      }

      final player = await FlameAudio.loop(
        'Slow_footsteps.wav',
        volume: volume,
      );
      if (!_footstepDesired || !LocalStorage.getSoundEnabled()) {
        try {
          await player.pause();
          await player.stop();
          await player.dispose();
        } catch (_) {}
        _footstepPlayer = null;
        _isFootstepPlaying = false;
      } else {
        _footstepPlayer = player;
      }
    } catch (_) {
      try {
        final player = await FlameAudio.loopLongAudio(
          'Slow_footsteps.wav',
          volume: volume,
        );
        if (!_footstepDesired || !LocalStorage.getSoundEnabled()) {
          try {
            await player.pause();
            await player.stop();
            await player.dispose();
          } catch (_) {}
          _footstepPlayer = null;
          _isFootstepPlaying = false;
        } else {
          _footstepPlayer = player;
        }
      } catch (_) {
        _isFootstepPlaying = false;
      }
    } finally {
      _isFootstepLoading = false;
      if (!_footstepDesired || !LocalStorage.getSoundEnabled()) {
        stopFootstep();
      }
    }
  }

  void stopFootstep() {
    _footstepDesired = false;
    _isFootstepPlaying = false;
    _isFootstepLoading = false;
    try {
      _footstepPlayer?.pause();
      _footstepPlayer?.stop();
      _footstepPlayer?.dispose();
    } catch (_) {}
    _footstepPlayer = null;
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

  AudioPlayer? _bgmPlayer;
  bool _bgmDesired = false;
  bool _isBgmLoading = false;

  void startBgm() {
    if (!LocalStorage.getMusicEnabled()) {
      stopBgm();
      return;
    }
    _bgmDesired = true;
    if (_isBgmLoading) return;
    _startBgmAsync();
  }

  Future<void> _startBgmAsync() async {
    if (!_bgmDesired || !LocalStorage.getMusicEnabled()) {
      return;
    }
    _isBgmLoading = true;
    try {
      if (_bgmPlayer != null) {
        if (_bgmDesired && LocalStorage.getMusicEnabled()) {
          await _bgmPlayer!.resume();
        } else {
          await _bgmPlayer!.pause();
          await _bgmPlayer!.stop();
          await _bgmPlayer!.dispose();
          _bgmPlayer = null;
        }
        _isBgmLoading = false;
        return;
      }

      final player = await FlameAudio.loopLongAudio('bgm.wav', volume: 0.45);
      if (!_bgmDesired || !LocalStorage.getMusicEnabled()) {
        try {
          await player.pause();
          await player.stop();
          await player.dispose();
        } catch (_) {}
        _bgmPlayer = null;
      } else {
        _bgmPlayer = player;
      }
    } catch (_) {
      try {
        FlameAudio.bgm.initialize();
        if (_bgmDesired && LocalStorage.getMusicEnabled()) {
          FlameAudio.bgm.play('bgm.wav', volume: 0.45);
        } else {
          FlameAudio.bgm.stop();
        }
      } catch (_) {
        try {
          if (_bgmDesired && LocalStorage.getMusicEnabled()) {
            final fallbackPlayer = await FlameAudio.loop(
              'bgm.wav',
              volume: 0.45,
            );
            if (!_bgmDesired || !LocalStorage.getMusicEnabled()) {
              try {
                await fallbackPlayer.pause();
                await fallbackPlayer.stop();
                await fallbackPlayer.dispose();
              } catch (_) {}
              _bgmPlayer = null;
            } else {
              _bgmPlayer = fallbackPlayer;
            }
          }
        } catch (_) {}
      }
    } finally {
      _isBgmLoading = false;
      if (!_bgmDesired || !LocalStorage.getMusicEnabled()) {
        stopBgm();
      }
    }
  }

  void stopBgm() {
    _bgmDesired = false;
    _isBgmLoading = false;
    try {
      _bgmPlayer?.pause();
      _bgmPlayer?.stop();
      _bgmPlayer?.dispose();
    } catch (_) {}
    _bgmPlayer = null;
    try {
      FlameAudio.bgm.pause();
      FlameAudio.bgm.stop();
    } catch (_) {}
  }
}
