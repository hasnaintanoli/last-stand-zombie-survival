
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../zombie_game.dart';
import 'particle_effects.dart';

class Bullet extends PositionComponent with HasGameReference<ZombieGame> {
  final Vector2 direction;
  final double speed;
  final double damage;
  final double maxRange;
  double distanceTraveled = 0.0;

  Bullet({
    required Vector2 position,
    required Vector2 direction,
    required this.speed,
    required this.damage,
    required this.maxRange,
  })  : direction = direction.normalized(),
        super(position: position, size: Vector2.all(8.0), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    final prevPos = position.clone();
    final delta = speed * dt;
    position += direction * delta;
    distanceTraveled += delta;

    if (distanceTraveled >= maxRange) {
      removeFromParent();
      return;
    }

    // (Map boundary check removed for infinite open world)


    // Check collision with zombies FIRST
    for (final zombie in game.zombies) {
      if (zombie.isAlive) {
        final distCurrent = (zombie.position - position).length;
        final distPrev = (zombie.position - prevPos).length;
        final minHitDist = zombie.radius + 14.0;

        if (distCurrent <= minHitDist || distPrev <= minHitDist || zombie.containsPoint(position)) {
          zombie.takeDamage(damage, direction);
          SpawnParticles.bloodBurst(game, position.clone(), direction);
          game.world.add(
            FloatingText(
              position: position.clone(),
              text: damage.toInt().toString(),
              color: Colors.amberAccent,
            ),
          );
          removeFromParent();
          return;
        }
      }
    }

    // Check collision with obstacles SECOND
    for (final obstacle in game.obstacles) {
      if (obstacle.containsPoint(position)) {
        removeFromParent();
        return;
      }
    }
  }


  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render tracer bullet line
    final trailPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.6)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final headPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = Colors.orangeAccent.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 6.0, glowPaint);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 3.0, headPaint);

    final tailEnd = Offset(
      size.x / 2 - direction.x * 12,
      size.y / 2 - direction.y * 12,
    );
    canvas.drawLine(Offset(size.x / 2, size.y / 2), tailEnd, trailPaint);
  }
}
