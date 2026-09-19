import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/audio_service.dart';
import '../services/local_storage.dart';
import 'config/game_config.dart';
import 'components/player.dart';
import 'components/zombie.dart';
import 'components/bullet.dart';
import 'components/obstacle.dart';
import 'components/pickup.dart';
import 'components/particle_effects.dart';
import 'systems/wave_manager.dart';
import 'systems/xp_system.dart';

class ZombieGame extends FlameGame
    with KeyboardEvents, MouseMovementDetector, TapCallbacks {
  late Player player;
  late WaveManager waveManager;
  final AudioService audio = AudioService();

  final List<Zombie> zombies = [];
  final List<Obstacle> obstacles = [];
  final Set<String> _generatedChunks = {};

  double survivalTime = 0.0;
  int totalZombiesKilled = 0;

  String? waveBannerText;
  double waveBannerTimer = 0.0;
  double screenShakeTimer = 0.0;

  List<Map<String, dynamic>> pendingUpgrades = [];

  // Desktop Keyboard movement vectors
  bool keyW = false;
  bool keyA = false;
  bool keyS = false;
  bool keyD = false;
  bool isMouseDown = false;
  Vector2 mouseWorldPosition = Vector2.zero();

  // Mobile joystick vector
  Vector2 joystickDelta = Vector2.zero();
  bool mobileShootPressed = false;

  ZombieGame();

  @override
  Color backgroundColor() => GameConfig.darkBg;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Responsive viewport size
    camera.viewport.size = Vector2(800, 600);

    // Setup Player at center
    player = Player(position: Vector2(1200, 1200));
    world.add(player);
    camera.follow(player);

    // Setup initial open world map environment
    _generateMapEnvironment();

    // Setup Wave Manager
    waveManager = WaveManager(this);
    waveManager.startFirstWave();

    // Start background music
    audio.startBgm();
  }


  void _generateMapEnvironment() {
    _updateProceduralWorld();
  }

  void _updateProceduralWorld() {
    if (!player.isMounted || !player.isAlive) return;

    final currentChunkX = (player.position.x / 400.0).floor();
    final currentChunkY = (player.position.y / 400.0).floor();

    // Generate 5x5 chunks around player position
    for (int dx = -3; dx <= 3; dx++) {
      for (int dy = -3; dy <= 3; dy++) {
        final cx = currentChunkX + dx;
        final cy = currentChunkY + dy;
        final key = '$cx,$cy';

        if (!_generatedChunks.contains(key)) {
          _generatedChunks.add(key);
          _generateChunk(cx, cy);
        }
      }
    }

    // Performance Cleanup: remove obstacles that are far away from player (>2500px)
    obstacles.removeWhere((obs) {
      final isFar = (obs.position - player.position).length > 2500.0;
      if (isFar) obs.removeFromParent();
      return isFar;
    });
  }

  void _generateChunk(int cx, int cy) {
    final chunkCenterX = cx * 400.0 + 200.0;
    final chunkCenterY = cy * 400.0 + 200.0;

    // Keep spawn center area around (1200, 1200) clear
    if ((Vector2(chunkCenterX, chunkCenterY) - Vector2(1200, 1200)).length < 300) return;

    // Deterministic random seed based on chunk coordinates
    final seed = (cx * 73856093) ^ (cy * 19349663);
    final rng = Random(seed);

    // 40% chance of spawning an obstacle in chunk
    if (rng.nextDouble() < 0.40) {
      final pos = Vector2(
        cx * 400.0 + 50.0 + rng.nextDouble() * 300.0,
        cy * 400.0 + 50.0 + rng.nextDouble() * 300.0,
      );

      final type = ObstacleType.values[rng.nextInt(ObstacleType.values.length)];
      Vector2 size;
      switch (type) {
        case ObstacleType.car:
          size = Vector2(60, 36);
          break;
        case ObstacleType.barrier:
          size = Vector2(48, 20);
          break;
        case ObstacleType.crate:
          size = Vector2(32, 32);
          break;
        case ObstacleType.lightPole:
          size = Vector2(24, 24);
          break;
        case ObstacleType.tree:
          size = Vector2(50, 50);
          break;
      }

      final obs = Obstacle(position: pos, size: size, type: type);
      obstacles.add(obs);
      world.add(obs);
    }

    // 15% chance of spawning a random pickup in chunk
    if (rng.nextDouble() < 0.15) {
      final pos = Vector2(
        cx * 400.0 + 60.0 + rng.nextDouble() * 280.0,
        cy * 400.0 + 60.0 + rng.nextDouble() * 280.0,
      );
      final pType = PickupType.values[rng.nextInt(PickupType.values.length)];
      world.add(Pickup(position: pos, type: pType));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (paused) return;

    if (player.isAlive) {
      survivalTime += dt;
      waveManager.update(dt);

      // Clean dead zombies
      zombies.removeWhere((z) => !z.isAlive || z.isRemoved);

      // Generate open world chunks & clean far objects
      _updateProceduralWorld();

      // Handle Controls Input (Mobile Joystick OR Desktop WASD)
      _processControls(dt);

      // Banner timer
      if (waveBannerTimer > 0) {
        waveBannerTimer -= dt;
        if (waveBannerTimer <= 0) {
          waveBannerText = null;
        }
      }

      // Screen shake timer
      if (screenShakeTimer > 0) {
        screenShakeTimer -= dt;
      }
    }
  }

  void _processControls(double dt) {
    Vector2 moveDir = Vector2.zero();

    // Mobile Joystick input takes priority if active
    if (joystickDelta.length > 0.1) {
      moveDir = joystickDelta.normalized();
    } else {
      // Desktop WASD
      if (keyW) moveDir.y -= 1;
      if (keyS) moveDir.y += 1;
      if (keyA) moveDir.x -= 1;
      if (keyD) moveDir.x += 1;
      if (moveDir.length > 0) moveDir = moveDir.normalized();
    }

    // Aim direction calculation
    Vector2? aimDir;
    
    // Check if mouse aiming position is active
    if (mouseWorldPosition.length > 0) {
      aimDir = mouseWorldPosition - player.position;
    }

    // Auto-aim at nearest zombie if shooting on mobile or when zombies are close
    if ((isMouseDown || mobileShootPressed) && (joystickDelta.length > 0.1 || aimDir == null || aimDir.length < 5.0)) {
      Zombie? nearestZombie;
      double nearestDist = 600.0; // Auto-aim detection radius

      for (final z in zombies) {
        if (z.isAlive) {
          final dist = (z.position - player.position).length;
          if (dist < nearestDist) {
            nearestDist = dist;
            nearestZombie = z;
          }
        }
      }

      if (nearestZombie != null) {
        aimDir = nearestZombie.position - player.position;
      }
    }

    player.updateInput(move: moveDir, aim: aimDir);

    // Continuous shoot if mouse held down OR mobile shoot button pressed
    if (isMouseDown || mobileShootPressed) {
      player.shoot();
    }
  }

  // Keyboard Event Handlers for Desktop
  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    keyW = keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);
    keyS = keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown);
    keyA = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    keyD = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    if (keysPressed.contains(LogicalKeyboardKey.keyR)) {
      player.reload();
    }
    if (keysPressed.contains(LogicalKeyboardKey.digit1)) {
      player.switchWeapon(0); // Pistol
    }
    if (keysPressed.contains(LogicalKeyboardKey.digit2)) {
      player.switchWeapon(1); // Shotgun
    }
    if (keysPressed.contains(LogicalKeyboardKey.digit3)) {
      player.switchWeapon(2); // Assault Rifle
    }

    return KeyEventResult.handled;
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    mouseWorldPosition = camera.globalToLocal(info.eventPosition.global);
  }

  @override
  void onTapDown(TapDownEvent event) {
    isMouseDown = true;
    mouseWorldPosition = camera.globalToLocal(event.canvasPosition);
  }

  @override
  void onTapUp(TapUpEvent event) {
    isMouseDown = false;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isMouseDown = false;
  }

  // Game Events
  void onZombieKilled(Zombie zombie) {
    totalZombiesKilled++;
    player.score += zombie.scoreReward;
    player.addXp(zombie.xpReward);
    waveManager.onZombieKilled();

    // Vampire perk heal
    if (player.vampireHealAmount > 0) {
      player.heal(player.vampireHealAmount);
    }
  }

  void onLevelUp() {
    audio.stopFootstep();
    audio.playLevelUp();
    pendingUpgrades = XpSystem.getRandomUpgrades();
    overlays.add('LevelUpOverlay');
    pauseEngine();
  }

  void selectUpgrade(String id) {
    XpSystem.applyUpgrade(player, id);
    overlays.remove('LevelUpOverlay');
    resumeEngine();
  }

  void showWaveBanner(String text) {
    waveBannerText = text;
    waveBannerTimer = 2.8;
  }

  void triggerScreenShake(double duration) {
    screenShakeTimer = duration;
  }

  void onPlayerDeath() {
    audio.stopFootstep();
    audio.stopBgm();
    audio.playGameOver();
    saveStats();
    overlays.add('GameOverOverlay');
    pauseEngine();
  }

  void saveStats() {
    LocalStorage.saveHighScore(player.score);
    LocalStorage.saveHighestWave(waveManager.currentWave);
    LocalStorage.addKills(totalZombiesKilled);
    LocalStorage.addCoins(player.coins);
  }

  void resetGame() {
    audio.stopFootstep();
    _generatedChunks.clear();
    zombies.clear();
    obstacles.clear();

    for (final c in world.children.toList()) {
      if (c is Zombie || c is Bullet || c is Pickup || c is BloodParticle || c is Obstacle) {
        c.removeFromParent();
      }
    }
    survivalTime = 0.0;
    totalZombiesKilled = 0;

    player.health = player.maxHealth;
    player.score = 0;
    player.level = 1;
    player.xp = 0;
    player.coins = 0;
    player.position = Vector2(1200, 1200);

    waveManager.startFirstWave();
    audio.startBgm();
    resumeEngine();
  }

  @override
  void onRemove() {
    audio.stopBgm();
    super.onRemove();
  }


  @override
  void render(Canvas canvas) {

    // Apply Screen Shake transform if active
    if (screenShakeTimer > 0) {
      final shakeX = (Random().nextDouble() - 0.5) * 8.0;
      final shakeY = (Random().nextDouble() - 0.5) * 8.0;
      canvas.save();
      canvas.translate(shakeX, shakeY);
    }

    // Render Infinite Map Asphalt & Moving City Grid
    _renderMapGrid(canvas);

    super.render(canvas);

    // Render Vignette Night Lighting Darkness Overlay
    _renderDarknessVignette(canvas);

    if (screenShakeTimer > 0) {
      canvas.restore();
    }
  }

  void _renderMapGrid(Canvas canvas) {
    final viewSize = camera.viewport.size;
    final bgPaint = Paint()..color = GameConfig.asphaltColor;

    // Fill visible screen viewport with asphalt background
    canvas.drawRect(Rect.fromLTWH(0, 0, viewSize.x, viewSize.y), bgPaint);

    final linePaint = Paint()
      ..color = GameConfig.roadLineColor
      ..strokeWidth = 3.0;

    // Calculate world bounds of current viewport relative to player position
    final worldLeft = player.position.x - viewSize.x / 2;
    final worldTop = player.position.y - viewSize.y / 2;
    final worldRight = player.position.x + viewSize.x / 2;
    final worldBottom = player.position.y + viewSize.y / 2;

    // Render Infinite Moving City Road Grid Lines (200px spacing)
    final startX = (worldLeft / 200.0).floor() * 200.0;
    for (double x = startX; x <= worldRight + 200; x += 200) {
      final screenX = x - worldLeft;
      canvas.drawLine(Offset(screenX, 0), Offset(screenX, viewSize.y), linePaint);
    }

    final startY = (worldTop / 200.0).floor() * 200.0;
    for (double y = startY; y <= worldBottom + 200; y += 200) {
      final screenY = y - worldTop;
      canvas.drawLine(Offset(0, screenY), Offset(viewSize.x, screenY), linePaint);
    }
  }

  void _renderDarknessVignette(Canvas canvas) {
    // Dark Vignette fog around camera view to enhance night survival atmosphere
    final viewSize = camera.viewport.size;
    final rect = Rect.fromLTWH(0, 0, viewSize.x, viewSize.y);
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.85,
      colors: [
        Colors.transparent,
        Colors.black.withValues(alpha: 0.75),
      ],
      stops: const [0.4, 1.0],
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }
}
