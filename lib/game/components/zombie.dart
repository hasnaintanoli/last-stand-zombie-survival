import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../zombie_game.dart';
import 'particle_effects.dart';
import 'pickup.dart';

enum ZombieType { normal, fast, tank, boss }

class Zombie extends PositionComponent with HasGameReference<ZombieGame> {
  final ZombieType type;
  double maxHealth;
  double health;
  double speed;
  double damage;
  int xpReward;
  int scoreReward;
  final double radius;

  bool get isAlive => health > 0;

  double _attackCooldown = 0.0;
  double _attackAnimTimer = 0.0;
  double _pounceTimer = 0.0;
  double _pounceCooldown = 0.0;
  double _hitFlashTimer = 0.0;
  double _walkAnimTimer = 0.0;
  double _twitchTimer = 0.0;
  double _zigzagTimer = 0.0;
  double _trailTimer = 0.0;
  double _dustTimer = 0.0;
  double _facingAngle = 0.0;
  Vector2 _knockbackVel = Vector2.zero();
  Vector2 _lastHitDir = Vector2(1, 0);

  Zombie({
    required Vector2 position,
    required this.type,
    required this.maxHealth,
    required this.speed,
    required this.damage,
    required this.xpReward,
    required this.scoreReward,
    required this.radius,
  }) : health = maxHealth,
       super(
         position: position,
         size: Vector2.all(radius * 2.6),
         anchor: Anchor.center,
       );

  factory Zombie.create({
    required Vector2 position,
    required ZombieType type,
    double waveMultiplier = 1.0,
  }) {
    switch (type) {
      case ZombieType.normal:
        return Zombie(
          position: position,
          type: type,
          maxHealth: 60.0 * waveMultiplier,
          speed: 80.0 * (1.0 + (waveMultiplier - 1.0) * 0.05),
          damage: 10.0 * waveMultiplier,
          xpReward: 12,
          scoreReward: 50,
          radius: 17.0,
        );
      case ZombieType.fast:
        return Zombie(
          position: position,
          type: type,
          maxHealth: 48.0 * waveMultiplier,
          speed: 175.0 * (1.0 + (waveMultiplier - 1.0) * 0.05),
          damage: 12.0 * waveMultiplier,
          xpReward: 20,
          scoreReward: 85,
          radius: 14.5,
        );
      case ZombieType.tank:
        return Zombie(
          position: position,
          type: type,
          maxHealth: 260.0 * waveMultiplier,
          speed: 60.0 * (1.0 + (waveMultiplier - 1.0) * 0.03),
          damage: 24.0 * waveMultiplier,
          xpReward: 35,
          scoreReward: 180,
          radius: 24.0,
        );
      case ZombieType.boss:
        return Zombie(
          position: position,
          type: type,
          maxHealth: 1200.0 * waveMultiplier,
          speed: 95.0 * (1.0 + (waveMultiplier - 1.0) * 0.03),
          damage: 38.0 * waveMultiplier,
          xpReward: 180,
          scoreReward: 1000,
          radius: 36.0,
        );
    }
  }

  @override
  bool containsPoint(Vector2 point) {
    return (point - position).length <= (radius + 12.0);
  }

  void takeDamage(double dmg, Vector2 bulletDir) {
    if (!isAlive) return;
    _lastHitDir = bulletDir.normalized();
    health -= dmg;
    _hitFlashTimer = 0.12;
    _knockbackVel =
        _lastHitDir *
        (type == ZombieType.boss
            ? 30.0
            : (type == ZombieType.fast ? 75.0 : 120.0));

    if (health <= 0) {
      _onDeath();
    }
  }

  void _onDeath() {
    game.audio.playZombieDeath();
    game.onZombieKilled(this);

    // 1. Spawn Unique Gory Death Particles & Corpses
    if (type == ZombieType.fast) {
      SpawnParticles.runnerDeathBurst(game, position.clone(), _lastHitDir);
      game.world.add(
        ZombieCorpse(
          position: position.clone(),
          facingAngle: _facingAngle,
          fatalDir: _lastHitDir,
          radius: radius,
          skinColor: _getSkinColor(),
          clothesColor: _getClothesColor(),
          isRunner: true,
        ),
      );
    } else {
      final goreScale = (type == ZombieType.boss
          ? 2.5
          : (type == ZombieType.tank ? 1.5 : 1.0));
      SpawnParticles.zombieDeathBurst(
        game,
        position.clone(),
        _lastHitDir,
        scale: goreScale,
      );
      game.world.add(
        ZombieCorpse(
          position: position.clone(),
          facingAngle: _facingAngle,
          fatalDir: _lastHitDir,
          radius: radius,
          skinColor: _getSkinColor(),
          clothesColor: _getClothesColor(),
          isRunner: false,
        ),
      );
    }

    // 2. Drop Pickup randomly
    final rng = Random();
    final dropRoll = rng.nextDouble();
    if (type == ZombieType.boss || dropRoll < 0.28) {
      PickupType dropType;
      if (type == ZombieType.boss) {
        dropType = PickupType.damageBoost;
      } else {
        final types = [
          PickupType.health,
          PickupType.ammo,
          PickupType.coin,
          PickupType.damageBoost,
        ];
        dropType = types[rng.nextInt(types.length)];
      }
      game.world.add(Pickup(position: position.clone(), type: dropType));
    }

    game.zombies.remove(this);
    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isAlive) return;

    _walkAnimTimer += dt * (type == ZombieType.fast ? 11.0 : 4.5);
    _twitchTimer += dt * (type == ZombieType.fast ? 7.5 : 3.0);
    if (_attackCooldown > 0) _attackCooldown -= dt;
    if (_hitFlashTimer > 0) _hitFlashTimer -= dt;
    if (_attackAnimTimer > 0) _attackAnimTimer -= dt;
    if (_pounceTimer > 0) _pounceTimer -= dt;
    if (_pounceCooldown > 0) _pounceCooldown -= dt;

    // Apply knockback decay
    if (_knockbackVel.length > 0) {
      position += _knockbackVel * dt;
      _knockbackVel *= 0.82;
    }

    final player = game.player;
    if (!player.isAlive) return;

    // Vector to Player
    final toPlayer = player.position - position;
    final distToPlayer = toPlayer.length;

    // Smoothly update facing direction towards player
    if (distToPlayer > 1.0) {
      _facingAngle = atan2(toPlayer.y, toPlayer.x);
    }

    // Flocking / Separation from other zombies
    Vector2 separation = Vector2.zero();
    int count = 0;
    for (final other in game.zombies) {
      if (other != this && other.isAlive) {
        final d = (position - other.position).length;
        if (d > 0 && d < (radius + other.radius + 10.0)) {
          separation += (position - other.position).normalized() / d;
          count++;
        }
      }
    }
    if (count > 0) separation /= count.toDouble();

    // Locomotion & Speed calculations
    double currentSpeed = speed;
    Vector2 moveDir = toPlayer.normalized();

    if (type == ZombieType.normal) {
      // Normal: Limp stride & uncoordinated weave
      final limpStride = 0.75 + 0.45 * sin(_walkAnimTimer * 2).clamp(0.0, 1.0);
      currentSpeed = speed * limpStride;

      final sideVector = Vector2(-moveDir.y, moveDir.x);
      final weave = sin(_walkAnimTimer * 0.7) * 0.18;
      moveDir = (moveDir + sideVector * weave).normalized();
    } else if (type == ZombieType.fast) {
      // Fast Runner: Sprinting speed trails & agile zig-zag flanking
      _zigzagTimer += dt * 6.5;

      // Motion Blur Afterimage & Trail
      _trailTimer += dt;
      final trailInterval = _pounceTimer > 0 ? 0.04 : 0.07;
      if (_trailTimer >= trailInterval) {
        _trailTimer = 0.0;
        SpawnParticles.runnerSpeedTrail(
          game,
          position,
          moveDir,
          _facingAngle,
          radius,
        );
      }

      // Ground sprint dust kick-up
      _dustTimer += dt;
      if (_dustTimer >= 0.09) {
        _dustTimer = 0.0;
        SpawnParticles.runnerSprintDust(game, position, moveDir);
      }

      // Agile Serpentine Zig-Zag flanking cuts
      if (_pounceTimer <= 0) {
        final sideVector = Vector2(-moveDir.y, moveDir.x);
        final zigZag = sin(_zigzagTimer) * 0.44;
        moveDir = (moveDir + sideVector * zigZag).normalized();
      }

      // Trigger Leaping Pounce surge when closing in
      if (distToPlayer < 125.0 &&
          distToPlayer > 30.0 &&
          _pounceCooldown <= 0 &&
          _pounceTimer <= 0) {
        _pounceTimer = 0.35;
        _pounceCooldown = 2.2 + Random().nextDouble() * 0.6;
        SpawnParticles.runnerPounceBurst(game, position, moveDir);
      }

      // Pounce Leap acceleration
      if (_pounceTimer > 0) {
        currentSpeed = speed * 1.95; // Explosive sprint surge
      }
    }

    if (separation.length > 0) {
      moveDir = (moveDir * 0.75 + separation * 0.25).normalized();
    }

    // Move toward player
    position += moveDir * currentSpeed * dt;

    // Map obstacle collision pushback
    for (final obstacle in game.obstacles) {
      if (obstacle.containsPoint(position)) {
        final pushDir = (position - obstacle.position).normalized();
        position += pushDir * 3.0;
      }
    }

    // Player Melee Attack Collision & Claw Swipe
    final attackRange =
        radius + player.radius + (type == ZombieType.fast ? 12.0 : 6.0);
    if (distToPlayer <= attackRange && _attackCooldown <= 0) {
      _attackAnimTimer = (type == ZombieType.fast
          ? 0.28
          : 0.35); // Snappy dual claw slash
      player.takeDamage(damage);
      game.audio.playZombieAttack();
      _attackCooldown = (type == ZombieType.fast
          ? 0.58
          : 1.0); // Runners attack with relentless speed
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset(size.x / 2, size.y / 2);

    if (type == ZombieType.normal) {
      _renderNormalZombie(canvas, center);
    } else if (type == ZombieType.fast) {
      _renderRunnerZombie(canvas, center);
    } else {
      _renderSpecialZombie(canvas, center);
    }

    // Health Bar above zombie head if damaged
    if (health < maxHealth && isAlive) {
      final barW = radius * 2.2;
      final barH = 4.0;
      final barRect = Rect.fromCenter(
        center: center - Offset(0, radius + 14),
        width: barW,
        height: barH,
      );
      final bgBar = Paint()..color = const Color(0xCC000000);
      final hpBar = Paint()..color = _getSkinColor();

      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(2)),
        bgBar,
      );
      final hpW = (health / maxHealth).clamp(0.0, 1.0) * barW;
      final fillRect = Rect.fromLTWH(barRect.left, barRect.top, hpW, barH);
      canvas.drawRRect(
        RRect.fromRectAndRadius(fillRect, const Radius.circular(2)),
        hpBar,
      );
    }
  }

  void _renderNormalZombie(Canvas canvas, Offset center) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_facingAngle);

    final limpFactor = sin(_walkAnimTimer);
    final headTwitch = sin(_twitchTimer * 3.5) * 0.10;
    final attackProgress = _attackAnimTimer > 0
        ? (_attackAnimTimer / 0.35)
        : 0.0;
    final attackLunge = sin(attackProgress * pi) * 10.0;

    // Hit reaction flash / shudder
    final isHit = _hitFlashTimer > 0;
    final shudderX = isHit ? (Random().nextDouble() - 0.5) * 3.0 : 0.0;
    final shudderY = isHit ? (Random().nextDouble() - 0.5) * 3.0 : 0.0;
    if (isHit) canvas.translate(shudderX, shudderY);

    final skinColor = isHit ? Colors.white : const Color(0xFF45633E);
    final clothesColor = isHit ? Colors.white : const Color(0xFF263328);
    final tornClothColor = isHit ? Colors.white : const Color(0xFF1E2620);
    final bloodColor = const Color(0xFF8B0000);
    final darkGoreColor = const Color(0xFF4A0000);

    // 1. Ground Shadow (sways with limp)
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.40);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-2.0, limpFactor * 1.5),
        width: radius * 2.2,
        height: radius * 1.6,
      ),
      shadowPaint,
    );

    // 2. Tattered Civilian Torso (Rounded Rect with rips)
    final torsoPaint = Paint()..color = clothesColor;
    final torsoPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(-2.0, 0),
            width: radius * 1.5,
            height: radius * 1.9,
          ),
          const Radius.circular(5.0),
        ),
      );
    canvas.drawPath(torsoPath, torsoPaint);

    // Torso Ripped Hemline & Flesh Patches
    final ripPaint = Paint()..color = tornClothColor;
    final ripPath = Path()
      ..moveTo(-radius * 0.8, -radius * 0.7)
      ..lineTo(-radius * 1.1, -radius * 0.3)
      ..lineTo(-radius * 0.8, 0)
      ..lineTo(-radius * 1.05, radius * 0.4)
      ..lineTo(-radius * 0.8, radius * 0.7)
      ..close();
    canvas.drawPath(ripPath, ripPaint);

    // Exposed Rotting Flesh / Blood Stains on Torso
    final bloodPaint = Paint()..color = bloodColor;
    canvas.drawCircle(
      Offset(-radius * 0.3, -radius * 0.25),
      radius * 0.25,
      bloodPaint,
    );
    canvas.drawCircle(
      Offset(-radius * 0.1, radius * 0.35),
      radius * 0.2,
      bloodPaint,
    );

    // 3. Reaching Arms & Bloody Claws
    final armSkinPaint = Paint()
      ..color = skinColor
      ..strokeWidth = radius * 0.32
      ..strokeCap = StrokeCap.round;

    final armSleevePaint = Paint()
      ..color = clothesColor
      ..strokeWidth = radius * 0.38
      ..strokeCap = StrokeCap.round;

    // Left Arm (Reaching Forward menacingly with swipe)
    final leftArmReach = radius * 1.3 + attackLunge + (limpFactor * 2.5);
    final leftArmY = -radius * 0.7 - (attackLunge * 0.2);
    // Shoulder sleeve
    canvas.drawLine(
      Offset(0, -radius * 0.65),
      Offset(radius * 0.5, -radius * 0.7),
      armSleevePaint,
    );
    // Forearm
    canvas.drawLine(
      Offset(radius * 0.4, -radius * 0.7),
      Offset(leftArmReach, leftArmY),
      armSkinPaint,
    );
    // Left Claw Fingers (3 claw points)
    final clawPaint = Paint()
      ..color = bloodColor
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(leftArmReach, leftArmY),
      Offset(leftArmReach + 5.0, leftArmY - 3.0),
      clawPaint,
    );
    canvas.drawLine(
      Offset(leftArmReach, leftArmY),
      Offset(leftArmReach + 6.0, leftArmY),
      clawPaint,
    );
    canvas.drawLine(
      Offset(leftArmReach, leftArmY),
      Offset(leftArmReach + 5.0, leftArmY + 3.0),
      clawPaint,
    );

    // Right Arm (Dragging / Limping reach)
    final rightArmReach = radius * 1.0 + attackLunge - (limpFactor * 3.5);
    final rightArmY = radius * 0.65 + (attackLunge * 0.2);
    // Shoulder sleeve
    canvas.drawLine(
      Offset(0, radius * 0.65),
      Offset(radius * 0.4, radius * 0.68),
      armSleevePaint,
    );
    // Forearm
    canvas.drawLine(
      Offset(radius * 0.35, radius * 0.68),
      Offset(rightArmReach, rightArmY),
      armSkinPaint,
    );
    // Right Claw Fingers
    canvas.drawLine(
      Offset(rightArmReach, rightArmY),
      Offset(rightArmReach + 5.0, rightArmY - 2.5),
      clawPaint,
    );
    canvas.drawLine(
      Offset(rightArmReach, rightArmY),
      Offset(rightArmReach + 5.5, rightArmY + 2.0),
      clawPaint,
    );

    // Claw Slash Effect during Attack
    if (_attackAnimTimer > 0) {
      final slashPaint = Paint()
        ..color = const Color(0xFFFF1744).withValues(alpha: attackProgress)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final slashPath = Path()
        ..moveTo(radius * 1.2, -radius * 1.1)
        ..quadraticBezierTo(radius * 1.8, 0, radius * 1.2, radius * 1.1);
      canvas.drawPath(slashPath, slashPaint);
    }

    // 4. Decayed Zombie Head (with head twitch)
    canvas.save();
    canvas.translate(radius * 0.45, 0);
    canvas.rotate(headTwitch);

    final headPaint = Paint()..color = skinColor;
    canvas.drawCircle(Offset.zero, radius * 0.72, headPaint);

    // Exposed skull/brain bloody wound on top-left of head
    final woundPaint = Paint()..color = darkGoreColor;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-radius * 0.2, -radius * 0.3),
        width: radius * 0.55,
        height: radius * 0.4,
      ),
      woundPaint,
    );
    canvas.drawCircle(
      Offset(-radius * 0.2, -radius * 0.3),
      radius * 0.15,
      Paint()..color = const Color(0xFFD32F2F),
    );

    // Dark Sunken Eye Sockets
    final socketPaint = Paint()..color = const Color(0xFF0F1A10);
    canvas.drawCircle(
      Offset(radius * 0.25, -radius * 0.28),
      radius * 0.22,
      socketPaint,
    );
    canvas.drawCircle(
      Offset(radius * 0.25, radius * 0.28),
      radius * 0.22,
      socketPaint,
    );

    // Glowing Bloodshot Undead Eyes
    final eyeGlowPaint = Paint()..color = const Color(0xFFFF1744);
    final eyePupilPaint = Paint()..color = const Color(0xFFFFEB3B);
    canvas.drawCircle(
      Offset(radius * 0.3, -radius * 0.28),
      radius * 0.13,
      eyeGlowPaint,
    );
    canvas.drawCircle(
      Offset(radius * 0.3, radius * 0.28),
      radius * 0.13,
      eyeGlowPaint,
    );
    canvas.drawCircle(
      Offset(radius * 0.34, -radius * 0.28),
      radius * 0.06,
      eyePupilPaint,
    );
    canvas.drawCircle(
      Offset(radius * 0.34, radius * 0.28),
      radius * 0.06,
      eyePupilPaint,
    );

    // Rotten Gaping Jaw & Teeth
    final mouthPaint = Paint()
      ..color = const Color(0xFF2A0000)
      ..style = PaintingStyle.fill;
    final mouthPath = Path()
      ..moveTo(radius * 0.35, -radius * 0.2)
      ..lineTo(radius * 0.65, 0)
      ..lineTo(radius * 0.35, radius * 0.2)
      ..close();
    canvas.drawPath(mouthPath, mouthPaint);

    // Jagged yellow teeth
    final teethPaint = Paint()
      ..color = const Color(0xFFE8E8A6)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(radius * 0.4, -radius * 0.12),
      Offset(radius * 0.5, -radius * 0.06),
      teethPaint,
    );
    canvas.drawLine(
      Offset(radius * 0.4, radius * 0.12),
      Offset(radius * 0.5, radius * 0.06),
      teethPaint,
    );

    canvas.restore(); // restore head

    canvas.restore(); // restore body
  }

  void _renderRunnerZombie(Canvas canvas, Offset center) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_facingAngle);

    final sprintFactor = sin(_walkAnimTimer);
    final isPouncing = _pounceTimer > 0;
    final pounceProgress = isPouncing ? (1.0 - (_pounceTimer / 0.35)) : 0.0;
    final pounceLeapZ = sin(pounceProgress * pi) * 16.0; // Height in air
    final pounceLungeX = sin(pounceProgress * pi) * 14.0;

    final attackProgress = _attackAnimTimer > 0
        ? (_attackAnimTimer / 0.28)
        : 0.0;
    final attackLunge = sin(attackProgress * pi) * 12.0;

    // Body Lean & Feral Sprint Bobbing
    final bodySprintSway = sin(_walkAnimTimer * 0.5) * 0.08;
    canvas.rotate(bodySprintSway);

    // Hit reaction flash / shudder
    final isHit = _hitFlashTimer > 0;
    final shudderX = isHit ? (Random().nextDouble() - 0.5) * 3.0 : 0.0;
    final shudderY = isHit ? (Random().nextDouble() - 0.5) * 3.0 : 0.0;
    if (isHit) canvas.translate(shudderX, shudderY);

    final skinColor = isHit
        ? Colors.white
        : const Color(0xFF9E2A2B); // Raw sinewy crimson muscle
    final darkFleshColor = isHit ? Colors.white : const Color(0xFF5A1215);
    final clothesColor = isHit
        ? Colors.white
        : const Color(0xFF220808); // Shredded dark crimson hoodie
    final tornClothColor = isHit ? Colors.white : const Color(0xFF140404);
    final clawColor = const Color(0xFFFF1744);
    final boneColor = const Color(0xFFE8E8A6);

    // 1. Dynamic Aerodynamic Ground Shadow (Reacts to Leap Height & Sprint Stride)
    final shadowScale = (1.0 - (pounceLeapZ / 26.0)).clamp(0.45, 1.0);
    final shadowAlpha = (0.38 * shadowScale).clamp(0.15, 0.38);
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: shadowAlpha);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-radius * 0.3 - (pounceLeapZ * 0.35), 0),
        width: (radius * 2.8 + (sprintFactor.abs() * 3.0)) * shadowScale,
        height: radius * 1.25 * shadowScale,
      ),
      shadowPaint,
    );

    // 2. Trailing Wind Streaks & Speed Ribbons behind shoulders
    final ribbonPaint = Paint()
      ..color = const Color(
        0xFFFF1744,
      ).withValues(alpha: isPouncing ? 0.70 : 0.40)
      ..strokeWidth = isPouncing ? 2.5 : 1.8
      ..strokeCap = StrokeCap.round;
    final wave1 = sin(_walkAnimTimer * 2.8) * 4.5;
    final wave2 = cos(_walkAnimTimer * 2.8) * 4.5;
    final ribbonLength = isPouncing ? radius * 2.4 : radius * 1.8;
    canvas.drawLine(
      Offset(-radius * 0.5, -radius * 0.5),
      Offset(-ribbonLength, -radius * 0.6 + wave1),
      ribbonPaint,
    );
    canvas.drawLine(
      Offset(-radius * 0.5, radius * 0.5),
      Offset(-ribbonLength, radius * 0.5 + wave2),
      ribbonPaint,
    );

    // 3. Hunched Feral Torso (Emaciated, aerodynamic spine thrust forward)
    final torsoPaint = Paint()..color = clothesColor;
    final torsoPath = Path()
      ..moveTo(radius * 0.5 + pounceLungeX * 0.3, 0)
      ..lineTo(-radius * 0.7, -radius * 0.58)
      ..lineTo(-radius * 1.1, 0)
      ..lineTo(-radius * 0.7, radius * 0.58)
      ..close();
    canvas.drawPath(torsoPath, torsoPaint);

    // Torn Hoodie Flapping Tails
    final shredPaint = Paint()..color = tornClothColor;
    final shredPath = Path()
      ..moveTo(-radius * 0.8, -radius * 0.4)
      ..lineTo(-radius * 1.35, -radius * 0.2 + wave1 * 0.5)
      ..lineTo(-radius * 1.0, 0)
      ..lineTo(-radius * 1.35, radius * 0.2 + wave2 * 0.5)
      ..lineTo(-radius * 0.8, radius * 0.4)
      ..close();
    canvas.drawPath(shredPath, shredPaint);

    // Exposed Spine Vertebrae Bumps along the arched back
    final spinePaint = Paint()..color = boneColor;
    for (int i = 0; i < 5; i++) {
      final waveSpine = sin(_walkAnimTimer * 2.0 + i * 0.6) * 1.2;
      canvas.drawCircle(
        Offset(-radius * 0.2 - (i * radius * 0.2), waveSpine),
        1.7,
        spinePaint,
      );
    }

    // Exposed Ribs / Sinewy Muscle Strands
    final musclePaint = Paint()
      ..color = darkFleshColor
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(-radius * 0.2, -radius * 0.42),
      Offset(radius * 0.15, -radius * 0.2),
      musclePaint,
    );
    canvas.drawLine(
      Offset(-radius * 0.2, radius * 0.42),
      Offset(radius * 0.15, radius * 0.2),
      musclePaint,
    );

    // 4. Razor Claw Arms (Alternating Sprint Pumps OR Savage Pounce/Attack Scissor Rake)
    final armSkinPaint = Paint()
      ..color = skinColor
      ..strokeWidth = radius * 0.28
      ..strokeCap = StrokeCap.round;

    final clawPaint = Paint()
      ..color = clawColor
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    if (isPouncing || _attackAnimTimer > 0) {
      // Pounce / Attack: Both Arms Lunge Forward in a Savage Cross-Scissor Slash
      final lungeReach = radius * 1.4 + pounceLungeX + attackLunge;
      // Left Arm Lunge
      canvas.drawLine(
        Offset(0, -radius * 0.5),
        Offset(lungeReach, -radius * 0.25),
        armSkinPaint,
      );
      // Right Arm Lunge
      canvas.drawLine(
        Offset(0, radius * 0.5),
        Offset(lungeReach, radius * 0.25),
        armSkinPaint,
      );

      // 3 Needle Sharp Razor Talons per hand
      // Left Hand Claws
      canvas.drawLine(
        Offset(lungeReach, -radius * 0.25),
        Offset(lungeReach + 8.5, -radius * 0.55),
        clawPaint,
      );
      canvas.drawLine(
        Offset(lungeReach, -radius * 0.25),
        Offset(lungeReach + 10.0, -radius * 0.25),
        clawPaint,
      );
      canvas.drawLine(
        Offset(lungeReach, -radius * 0.25),
        Offset(lungeReach + 8.5, 0),
        clawPaint,
      );

      // Right Hand Claws
      canvas.drawLine(
        Offset(lungeReach, radius * 0.25),
        Offset(lungeReach + 8.5, 0),
        clawPaint,
      );
      canvas.drawLine(
        Offset(lungeReach, radius * 0.25),
        Offset(lungeReach + 10.0, radius * 0.25),
        clawPaint,
      );
      canvas.drawLine(
        Offset(lungeReach, radius * 0.25),
        Offset(lungeReach + 8.5, radius * 0.55),
        clawPaint,
      );

      // Sweeping Dual Crimson Slash Wave Arcs
      final slashIntensity = (isPouncing ? pounceProgress : attackProgress);
      final slashPaint = Paint()
        ..color = const Color(
          0xFFFF1744,
        ).withValues(alpha: (slashIntensity).clamp(0.0, 1.0))
        ..strokeWidth = 3.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final slash1 = Path()
        ..moveTo(radius * 1.0, -radius * 1.3)
        ..quadraticBezierTo(radius * 2.2, 0, radius * 1.1, radius * 1.0);
      final slash2 = Path()
        ..moveTo(radius * 1.0, radius * 1.3)
        ..quadraticBezierTo(radius * 2.2, 0, radius * 1.1, -radius * 1.0);
      canvas.drawPath(slash1, slashPaint);
      canvas.drawPath(slash2, slashPaint);
    } else {
      // Sprinting Arm Cycle: High-speed alternating pumps with claw motion blur
      final arm1Reach = radius * 1.15 + (sprintFactor * 6.5);
      final arm2Reach = radius * 1.15 - (sprintFactor * 6.5);

      canvas.drawLine(
        Offset(0, -radius * 0.5),
        Offset(arm1Reach, -radius * 0.55),
        armSkinPaint,
      );
      canvas.drawLine(
        Offset(0, radius * 0.5),
        Offset(arm2Reach, radius * 0.55),
        armSkinPaint,
      );

      // 3 Sharp claw points per hand
      // Hand 1
      canvas.drawLine(
        Offset(arm1Reach, -radius * 0.55),
        Offset(arm1Reach + 6.5, -radius * 0.72),
        clawPaint,
      );
      canvas.drawLine(
        Offset(arm1Reach, -radius * 0.55),
        Offset(arm1Reach + 7.5, -radius * 0.55),
        clawPaint,
      );
      canvas.drawLine(
        Offset(arm1Reach, -radius * 0.55),
        Offset(arm1Reach + 6.5, -radius * 0.38),
        clawPaint,
      );

      // Hand 2
      canvas.drawLine(
        Offset(arm2Reach, radius * 0.55),
        Offset(arm2Reach + 6.5, radius * 0.38),
        clawPaint,
      );
      canvas.drawLine(
        Offset(arm2Reach, radius * 0.55),
        Offset(arm2Reach + 7.5, radius * 0.55),
        clawPaint,
      );
      canvas.drawLine(
        Offset(arm2Reach, radius * 0.55),
        Offset(arm2Reach + 6.5, radius * 0.72),
        clawPaint,
      );
    }

    // 5. Feral Predator Head & Snarling Snout (Hunched Low Forward)
    canvas.save();
    canvas.translate(radius * 0.55 + (pounceLungeX * 0.4), 0);

    // Rapid rabid head twitching
    final rabidTwitch = sin(_twitchTimer * 8.5) * 0.14;
    canvas.rotate(rabidTwitch);

    final headPaint = Paint()..color = skinColor;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 1.15,
        height: radius * 0.88,
      ),
      headPaint,
    );

    // Piercing Glowing Red/Amber Predator Eyes with Inner Flare
    final eyeAura = Paint()..color = const Color(0xFFFF1744);
    final eyeCore = Paint()..color = const Color(0xFFFFD600);
    final eyePupil = Paint()..color = Colors.white;

    // Left Eye
    canvas.drawCircle(
      Offset(radius * 0.28, -radius * 0.24),
      radius * 0.18,
      eyeAura,
    );
    canvas.drawCircle(
      Offset(radius * 0.32, -radius * 0.24),
      radius * 0.10,
      eyeCore,
    );
    canvas.drawCircle(
      Offset(radius * 0.35, -radius * 0.24),
      radius * 0.04,
      eyePupil,
    );

    // Right Eye
    canvas.drawCircle(
      Offset(radius * 0.28, radius * 0.24),
      radius * 0.18,
      eyeAura,
    );
    canvas.drawCircle(
      Offset(radius * 0.32, radius * 0.24),
      radius * 0.10,
      eyeCore,
    );
    canvas.drawCircle(
      Offset(radius * 0.35, radius * 0.24),
      radius * 0.04,
      eyePupil,
    );

    // Snarl Maw with Exposed Sharp Interlocking Bone Fangs
    final mawPaint = Paint()..color = const Color(0xFF260000);
    final mawPath = Path()
      ..moveTo(radius * 0.3, -radius * 0.2)
      ..lineTo(radius * 0.72, 0)
      ..lineTo(radius * 0.3, radius * 0.2)
      ..close();
    canvas.drawPath(mawPath, mawPaint);

    // Interlocking razor fangs
    final fangPaint = Paint()
      ..color = boneColor
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(radius * 0.38, -radius * 0.14),
      Offset(radius * 0.50, -radius * 0.05),
      fangPaint,
    );
    canvas.drawLine(
      Offset(radius * 0.48, -radius * 0.12),
      Offset(radius * 0.58, -radius * 0.04),
      fangPaint,
    );
    canvas.drawLine(
      Offset(radius * 0.38, radius * 0.14),
      Offset(radius * 0.50, radius * 0.05),
      fangPaint,
    );
    canvas.drawLine(
      Offset(radius * 0.48, radius * 0.12),
      Offset(radius * 0.58, radius * 0.04),
      fangPaint,
    );

    // Blood / Saliva froth specks at corner of mouth
    final frothPaint = Paint()..color = const Color(0xFFD32F2F);
    canvas.drawCircle(Offset(radius * 0.65, -radius * 0.08), 1.3, frothPaint);
    canvas.drawCircle(Offset(radius * 0.65, radius * 0.08), 1.3, frothPaint);

    canvas.restore(); // restore head

    canvas.restore(); // restore body
  }

  void _renderSpecialZombie(Canvas canvas, Offset center) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_facingAngle);

    final walkWobble = sin(_walkAnimTimer) * 2.0;

    // Shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.45);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-2.0, radius * 0.4),
        width: radius * 2.0,
        height: radius * 1.2,
      ),
      shadowPaint,
    );

    // Boss Pulsing Aura
    if (type == ZombieType.boss) {
      final auraPaint = Paint()
        ..color = Colors.redAccent.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14.0);
      canvas.drawCircle(Offset.zero, radius * 1.5, auraPaint);
    }

    // Body Paint
    Paint bodyPaint;
    if (_hitFlashTimer > 0) {
      bodyPaint = Paint()..color = Colors.white;
    } else {
      bodyPaint = Paint()..color = _getSkinColor();
    }

    // Draw Zombie Torso
    canvas.drawCircle(Offset(walkWobble * 0.5, 0), radius, bodyPaint);

    // Arm details
    final armPaint = Paint()
      ..color = _getSkinColor()
      ..strokeWidth = radius * 0.35
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, -radius * 0.7),
      Offset(radius * 1.1 + walkWobble, -radius * 0.7),
      armPaint,
    );
    canvas.drawLine(
      Offset(0, radius * 0.7),
      Offset(radius * 1.1 - walkWobble, radius * 0.7),
      armPaint,
    );

    // Glowing Red Eyes
    final eyePaint = Paint()..color = const Color(0xFFFF1744);
    canvas.drawCircle(
      Offset(radius * 0.5, -radius * 0.35),
      radius * 0.2,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(radius * 0.5, radius * 0.35),
      radius * 0.2,
      eyePaint,
    );

    canvas.restore();
  }

  Color _getSkinColor() {
    switch (type) {
      case ZombieType.normal:
        return const Color(0xFF45633E); // Decayed Greenish-grey
      case ZombieType.fast:
        return const Color(0xFF8B2525); // Crimson Red Raw Muscle
      case ZombieType.tank:
        return const Color(0xFF303F9F); // Dark Armored Blue
      case ZombieType.boss:
        return const Color(0xFF8E24AA); // Boss Purple
    }
  }

  Color _getClothesColor() {
    switch (type) {
      case ZombieType.normal:
        return const Color(0xFF263328); // Dark Tattered Green/Grey Shirt
      case ZombieType.fast:
        return const Color(0xFF2A0A0A); // Shredded Dark Crimson Hoodie
      case ZombieType.tank:
        return const Color(0xFF1B263B);
      case ZombieType.boss:
        return const Color(0xFF2E0854);
    }
  }
}
