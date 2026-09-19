import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../zombie_game.dart';
import 'particle_effects.dart';
import 'player.dart';

enum PickupType { health, ammo, coin, damageBoost }

class Pickup extends PositionComponent with HasGameReference<ZombieGame> {
  final PickupType type;
  double _bobTimer = 0.0;
  final double magneticDistance = 140.0;
  final double baseSpeed = 220.0;

  Pickup({
    required Vector2 position,
    required this.type,
  }) : super(position: position, size: Vector2.all(28.0), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    _bobTimer += dt * 4.0;

    // Magnetic Attraction to Player
    final player = game.player;
    if (player.isAlive) {
      final dist = (player.position - position).length;
      final effectiveMagnetDist = magneticDistance * player.magnetMultiplier;
      if (dist <= effectiveMagnetDist) {
        final dir = (player.position - position).normalized();
        final pullSpeed = baseSpeed * (1.0 - (dist / effectiveMagnetDist).clamp(0.0, 0.8)) + 100.0;
        position += dir * pullSpeed * dt;

        // Pickup collection
        if (dist <= 24.0) {
          _applyPickup(player);
          removeFromParent();
        }
      }
    }
  }

  void _applyPickup(Player player) {
    switch (type) {
      case PickupType.health:
        player.heal(35.0);
        game.world.add(
          FloatingText(
            position: position.clone(),
            text: '+35 HP',
            color: Colors.greenAccent,
          ),
        );
        break;
      case PickupType.ammo:
        player.refillCurrentAmmo();
        game.world.add(
          FloatingText(
            position: position.clone(),
            text: '+AMMO',
            color: Colors.amberAccent,
          ),
        );
        break;
      case PickupType.coin:
        player.addCoins(10);
        game.world.add(
          FloatingText(
            position: position.clone(),
            text: '+10 COINS',
            color: Colors.yellowAccent,
          ),
        );
        break;
      case PickupType.damageBoost:
        player.applyDamageBoost(10.0); // 10 seconds 2x damage
        game.world.add(
          FloatingText(
            position: position.clone(),
            text: '2X DAMAGE!',
            color: Colors.purpleAccent,
          ),
        );
        break;
    }
    game.audio.playPickup();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final bobOffset = sin(_bobTimer) * 3.0;
    final center = Offset(size.x / 2, size.y / 2 + bobOffset);

    // Glow Halo
    final glowColor = _getColor().withValues(alpha: 0.35);
    final glowPaint = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawCircle(center, 18.0, glowPaint);

    // Base Crate / Badge
    final bgPaint = Paint()..color = const Color(0xFF1E222A);
    final borderPaint = Paint()
      ..color = _getColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final rect = Rect.fromCenter(center: center, width: 22, height: 22);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    canvas.drawRRect(rrect, bgPaint);
    canvas.drawRRect(rrect, borderPaint);

    // Draw Icon Symbol inside
    _drawSymbol(canvas, center);
  }

  Color _getColor() {
    switch (type) {
      case PickupType.health:
        return Colors.greenAccent;
      case PickupType.ammo:
        return Colors.amberAccent;
      case PickupType.coin:
        return Colors.yellow;
      case PickupType.damageBoost:
        return Colors.purpleAccent;
    }
  }

  void _drawSymbol(Canvas canvas, Offset center) {
    final symbolPaint = Paint()
      ..color = _getColor()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.5;

    switch (type) {
      case PickupType.health:
        // Cross +
        canvas.drawRect(
            Rect.fromCenter(center: center, width: 10, height: 3.5), symbolPaint);
        canvas.drawRect(
            Rect.fromCenter(center: center, width: 3.5, height: 10), symbolPaint);
        break;

      case PickupType.ammo:
        // Ammo Bullet icon
        canvas.drawRect(
            Rect.fromCenter(center: center - const Offset(3, 0), width: 3, height: 8),
            symbolPaint);
        canvas.drawRect(
            Rect.fromCenter(center: center + const Offset(3, 0), width: 3, height: 8),
            symbolPaint);
        break;

      case PickupType.coin:
        // Gold Coin $
        canvas.drawCircle(center, 5.0, symbolPaint);
        break;

      case PickupType.damageBoost:
        // Lightning Bolt
        final path = Path()
          ..moveTo(center.dx + 2, center.dy - 6)
          ..lineTo(center.dx - 3, center.dy + 1)
          ..lineTo(center.dx, center.dy + 1)
          ..lineTo(center.dx - 2, center.dy + 6)
          ..lineTo(center.dx + 3, center.dy - 1)
          ..lineTo(center.dx, center.dy - 1)
          ..close();
        canvas.drawPath(path, symbolPaint);
        break;
    }
  }
}
