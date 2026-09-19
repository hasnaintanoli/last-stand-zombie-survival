import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../zombie_game.dart';

class BloodParticle extends PositionComponent with HasGameReference<ZombieGame> {
  Vector2 velocity;
  final Color color;
  final double radius;
  double opacity = 1.0;
  final double lifetime;
  double _timer = 0;

  BloodParticle({
    required Vector2 position,
    required this.velocity,
    this.color = const Color(0xFFB71C1C),
    this.radius = 3.0,
    this.lifetime = 0.6,
  }) : super(position: position, size: Vector2.all(radius * 2));

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    position += velocity * dt;
    velocity *= 0.92; // Friction deceleration
    opacity = (1.0 - (_timer / lifetime)).clamp(0.0, 1.0);
    if (_timer >= lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(radius, radius), radius, paint);
  }
}

class MuzzleFlashEffect extends PositionComponent with HasGameReference<ZombieGame> {
  final double angleRad;
  double opacity = 1.0;
  final double duration = 0.08;
  double _timer = 0;

  MuzzleFlashEffect({
    required Vector2 position,
    required this.angleRad,
  }) : super(position: position, size: Vector2(24, 16));

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    opacity = (1.0 - (_timer / duration)).clamp(0.0, 1.0);
    if (_timer >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.save();
    canvas.rotate(angleRad);

    final flashPaint = Paint()
      ..color = Colors.amber.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    final innerPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, -6)
      ..lineTo(24, 0)
      ..lineTo(0, 6)
      ..close();

    canvas.drawPath(path, flashPaint);
    canvas.drawCircle(const Offset(4, 0), 6, innerPaint);

    canvas.restore();
  }
}

class FloatingText extends PositionComponent with HasGameReference<ZombieGame> {
  final String text;
  final Color color;
  final double lifetime;
  double _timer = 0;
  late TextPainter _textPainter;

  FloatingText({
    required Vector2 position,
    required this.text,
    required this.color,
    this.lifetime = 0.9,
  }) : super(position: position) {
    _textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    position.y -= 25.0 * dt; // Float upwards
    if (_timer >= lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final opacity = (1.0 - (_timer / lifetime)).clamp(0.0, 1.0);
    canvas.save();
    _textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        color: color.withValues(alpha: opacity),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
              color: Colors.black.withValues(alpha: opacity),
              blurRadius: 4,
              offset: const Offset(1, 1))
        ],
      ),
    );
    _textPainter.layout();
    _textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }
}

class SpawnParticles {
  static void bloodBurst(ZombieGame game, Vector2 pos, Vector2 bulletDir) {
    final rng = Random();
    for (int i = 0; i < 8; i++) {
      final angle = atan2(bulletDir.y, bulletDir.x) + (rng.nextDouble() - 0.5) * 1.2;
      final speed = 80.0 + rng.nextDouble() * 120.0;
      final vel = Vector2(cos(angle), sin(angle)) * speed;
      game.world.add(
        BloodParticle(
          position: pos.clone(),
          velocity: vel,
          color: i % 2 == 0 ? const Color(0xFF8B0000) : const Color(0xFFD32F2F),
          radius: 2.0 + rng.nextDouble() * 3.0,
          lifetime: 0.4 + rng.nextDouble() * 0.4,
        ),
      );
    }
  }
}
