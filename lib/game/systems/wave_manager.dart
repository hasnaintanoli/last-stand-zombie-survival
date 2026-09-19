import 'dart:math';
import 'package:flame/components.dart';
import '../zombie_game.dart';
import '../components/zombie.dart';

class WaveManager {
  final ZombieGame game;
  int currentWave = 1;
  int totalZombiesInWave = 5;
  int zombiesSpawned = 0;
  int zombiesKilledInWave = 0;

  bool isWaveActive = false;
  double _spawnTimer = 0.0;
  double _spawnInterval = 1.8;
  double restTimer = 0.0;
  bool isResting = false;

  WaveManager(this.game);

  void startFirstWave() {
    currentWave = 1;
    _setupWave(currentWave);
  }

  void _setupWave(int wave) {
    currentWave = wave;
    totalZombiesInWave = 4 + (wave * 3);
    zombiesSpawned = 0;
    zombiesKilledInWave = 0;
    _spawnInterval = max(0.4, 2.0 - (wave * 0.1));
    isWaveActive = true;
    isResting = false;
    game.showWaveBanner('WAVE $currentWave');
  }

  void update(double dt) {
    if (isResting) {
      restTimer -= dt;
      if (restTimer <= 0) {
        _setupWave(currentWave + 1);
      }
      return;
    }

    if (!isWaveActive) return;

    if (zombiesSpawned < totalZombiesInWave) {
      _spawnTimer += dt;
      if (_spawnTimer >= _spawnInterval) {
        _spawnTimer = 0;
        _spawnZombieForWave();
      }
    }

    // Check if wave cleared
    if (zombiesKilledInWave >= totalZombiesInWave && game.zombies.isEmpty) {
      isWaveActive = false;
      isResting = true;
      restTimer = 4.0; // 4 seconds rest before next wave
      game.showWaveBanner('WAVE $currentWave CLEARED!');
      game.saveStats();
    }
  }

  void onZombieKilled() {
    zombiesKilledInWave++;
  }

  void _spawnZombieForWave() {
    final rng = Random();
    ZombieType type = ZombieType.normal;

    final isBossWave = (currentWave % 5 == 0);
    if (isBossWave && zombiesSpawned == totalZombiesInWave - 1) {
      type = ZombieType.boss;
    } else {
      final roll = rng.nextDouble();
      if (currentWave >= 3 && roll < 0.20) {
        type = ZombieType.tank;
      } else if (currentWave >= 2 && roll < 0.50) {
        type = ZombieType.fast;
      }
    }

    // Spawn position off-screen in circle around player
    final angle = rng.nextDouble() * 2 * pi;
    final distance = 600.0 + rng.nextDouble() * 200.0;
    final spawnPos = game.player.position + Vector2(cos(angle), sin(angle)) * distance;

    // Spawn zombies in circle around player anywhere in infinite world


    final waveMultiplier = 1.0 + (currentWave - 1) * 0.15;
    final zombie = Zombie.create(
      position: spawnPos,
      type: type,
      waveMultiplier: waveMultiplier,
    );

    game.zombies.add(zombie);
    game.world.add(zombie);
    zombiesSpawned++;
  }
}
