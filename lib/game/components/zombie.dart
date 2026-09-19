import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../zombie_game.dart';
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
  double _hitFlashTimer = 0.0;
  double _walkAnimTimer = 0.0;
  Vector2 _knockbackVel = Vector2.zero();

  Zombie({
    required Vector2 position,
    required this.type,
    required this.maxHealth,
    required this.speed,
    required this.damage,
    required this.xpReward,
    required this.scoreReward,
    required this.radius,
  })  : health = maxHealth,
        super(
          position: position,
          size: Vector2.all(radius * 2),
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
          radius: 16.0,
        );
      case ZombieType.fast:
        return Zombie(
          position: position,
          type: type,
          maxHealth: 45.0 * waveMultiplier,
          speed: 160.0 * (1.0 + (waveMultiplier - 1.0) * 0.05),
          damage: 12.0 * waveMultiplier,
          xpReward: 18,
          scoreReward: 75,
          radius: 14.0,
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
    health -= dmg;
    _hitFlashTimer = 0.12;
    _knockbackVel = bulletDir.normalized() * (type == ZombieType.boss ? 30.0 : 120.0);

    if (health <= 0) {
      _onDeath();
    }
  }

  void _onDeath() {
    game.audio.playZombieDeath();
    game.onZombieKilled(this);

    // Drop Pickup randomly
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
          PickupType.damageBoost
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

    _walkAnimTimer += dt * 6.0;
    if (_attackCooldown > 0) _attackCooldown -= dt;
    if (_hitFlashTimer > 0) _hitFlashTimer -= dt;

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

    // Flocking / Separation from other zombies
    Vector2 separation = Vector2.zero();
    int count = 0;
    for (final other in game.zombies) {
      if (other != this && other.isAlive) {
        final d = (position - other.position).length;
        if (d > 0 && d < (radius + other.radius + 8.0)) {
          separation += (position - other.position).normalized() / d;
          count++;
        }
      }
    }
    if (count > 0) separation /= count.toDouble();

    // Combined AI Direction
    Vector2 moveDir = toPlayer.normalized();
    if (separation.length > 0) {
      moveDir = (moveDir * 0.75 + separation * 0.25).normalized();
    }

    // Move toward player
    position += moveDir * speed * dt;

    // Map obstacle collision pushback
    for (final obstacle in game.obstacles) {
      if (obstacle.containsPoint(position)) {
        final pushDir = (position - obstacle.position).normalized();
        position += pushDir * 3.0;
      }
    }

    // Player Melee Attack Collision
    if (distToPlayer <= (radius + player.radius) && _attackCooldown <= 0) {
      player.takeDamage(damage);
      game.audio.playZombieAttack();
      _attackCooldown = 1.0; // 1 second attack cooldown
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset(size.x / 2, size.y / 2);
    final walkWobble = sin(_walkAnimTimer) * (type == ZombieType.fast ? 4.0 : 2.0);

    // Render Shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.45);
    canvas.drawOval(
      Rect.fromCenter(
          center: center + Offset(0, radius * 0.8),
          width: radius * 1.8,
          height: radius * 0.8),
      shadowPaint,
    );

    // Body Paint
    Paint bodyPaint;
    if (_hitFlashTimer > 0) {
      bodyPaint = Paint()..color = Colors.white;
    } else {
      bodyPaint = Paint()..color = _getZombieColor();
    }

    // Boss Pulsing Aura
    if (type == ZombieType.boss) {
      final auraPaint = Paint()
        ..color = Colors.redAccent.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
      canvas.drawCircle(center, radius * 1.4, auraPaint);
    }

    // Draw Zombie Body (Torso & Head)
    canvas.drawCircle(center + Offset(walkWobble, 0), radius, bodyPaint);

    // Decay / Clothes outlines
    final outlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center + Offset(walkWobble, 0), radius, outlinePaint);

    // Glowing Red Eyes facing player direction
    final player = game.player;
    final aimAngle = (player.position - position).angleToSigned(Vector2(1, 0));
    final eyeOffset1 = Offset(
      center.dx + cos(-aimAngle - 0.35) * (radius * 0.5),
      center.dy + sin(-aimAngle - 0.35) * (radius * 0.5),
    );
    final eyeOffset2 = Offset(
      center.dx + cos(-aimAngle + 0.35) * (radius * 0.5),
      center.dy + sin(-aimAngle + 0.35) * (radius * 0.5),
    );

    final eyePaint = Paint()..color = const Color(0xFFFF1744);
    canvas.drawCircle(eyeOffset1, radius * 0.2, eyePaint);
    canvas.drawCircle(eyeOffset2, radius * 0.2, eyePaint);

    // Health Bar above zombie head if damaged
    if (health < maxHealth && isAlive) {
      final barW = radius * 2.2;
      final barH = 4.0;
      final barRect = Rect.fromCenter(
        center: center - Offset(0, radius + 10),
        width: barW,
        height: barH,
      );
      final bgBar = Paint()..color = const Color(0xCC000000);
      final hpBar = Paint()..color = _getZombieColor();

      canvas.drawRRect(
          RRect.fromRectAndRadius(barRect, const Radius.circular(2)), bgBar);
      final hpW = (health / maxHealth).clamp(0.0, 1.0) * barW;
      final fillRect = Rect.fromLTWH(
        barRect.left,
        barRect.top,
        hpW,
        barH,
      );
      canvas.drawRRect(
          RRect.fromRectAndRadius(fillRect, const Radius.circular(2)), hpBar);
    }
  }

  Color _getZombieColor() {
    switch (type) {
      case ZombieType.normal:
        return const Color(0xFF388E3C); // Decay Green
      case ZombieType.fast:
        return const Color(0xFFD32F2F); // Crimson Red
      case ZombieType.tank:
        return const Color(0xFF303F9F); // Dark Armored Blue/Purple
      case ZombieType.boss:
        return const Color(0xFF8E24AA); // Pulsing Boss Purple
    }
  }
}
