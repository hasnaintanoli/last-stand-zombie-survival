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

class GoreChunkParticle extends PositionComponent with HasGameReference<ZombieGame> {
  Vector2 velocity;
  final Color color;
  final double radius;
  double opacity = 1.0;
  final double lifetime;
  double _timer = 0;
  double rotation = 0;
  final double rotSpeed;

  GoreChunkParticle({
    required Vector2 position,
    required this.velocity,
    required this.color,
    required this.radius,
    required this.lifetime,
    required this.rotSpeed,
  }) : super(position: position, size: Vector2.all(radius * 2), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    position += velocity * dt;
    velocity *= 0.88; // Friction
    rotation += rotSpeed * dt;
    opacity = (1.0 - (_timer / lifetime)).clamp(0.0, 1.0);
    if (_timer >= lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.save();
    canvas.translate(radius, radius);
    canvas.rotate(rotation);
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(-radius, -radius * 0.5)
      ..lineTo(radius * 0.8, -radius)
      ..lineTo(radius, radius * 0.6)
      ..lineTo(-radius * 0.4, radius)
      ..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }
}

class SpeedTrailParticle extends PositionComponent with HasGameReference<ZombieGame> {
  final Color color;
  final double radius;
  double opacity = 0.5;
  final double lifetime = 0.22;
  double _timer = 0;

  SpeedTrailParticle({
    required Vector2 position,
    required this.color,
    required this.radius,
  }) : super(position: position, size: Vector2.all(radius * 2), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    opacity = (0.5 * (1.0 - (_timer / lifetime))).clamp(0.0, 0.5);
    if (_timer >= lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawCircle(Offset(radius, radius), radius, paint);
  }
}

class RunnerGhostAfterimage extends PositionComponent with HasGameReference<ZombieGame> {
  final double facingAngle;
  final double radius;
  final Color color;
  final double lifetime;
  double _timer = 0;

  RunnerGhostAfterimage({
    required Vector2 position,
    required this.facingAngle,
    required this.radius,
    this.color = const Color(0xFFE53935),
    this.lifetime = 0.16,
  }) : super(
          position: position,
          size: Vector2.all(radius * 2.6),
          anchor: Anchor.center,
          priority: 0,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer >= lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_timer / lifetime).clamp(0.0, 1.0);
    final alpha = (0.45 * (1.0 - progress)).clamp(0.0, 0.45);
    final center = Offset(size.x / 2, size.y / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(facingAngle);

    final ghostPaint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5)
      ..style = PaintingStyle.fill;

    // Hunched runner silhouette
    final path = Path()
      ..moveTo(radius * 0.9, 0)
      ..lineTo(-radius * 0.7, -radius * 0.55)
      ..lineTo(-radius * 1.0, 0)
      ..lineTo(-radius * 0.7, radius * 0.55)
      ..close();
    canvas.drawPath(path, ghostPaint);

    // Reaching claws silhouette
    final clawPaint = Paint()
      ..color = const Color(0xFFFF1744).withValues(alpha: alpha * 0.8)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, -radius * 0.5), Offset(radius * 1.3, -radius * 0.4), clawPaint);
    canvas.drawLine(Offset(0, radius * 0.5), Offset(radius * 1.3, radius * 0.4), clawPaint);

    canvas.restore();
  }
}

class RunnerGroundDust extends PositionComponent with HasGameReference<ZombieGame> {
  Vector2 velocity;
  final Color color;
  final double radius;
  final double lifetime;
  double _timer = 0;

  RunnerGroundDust({
    required Vector2 position,
    required this.velocity,
    this.color = const Color(0xFF6D4C41),
    this.radius = 2.5,
    this.lifetime = 0.28,
  }) : super(position: position, size: Vector2.all(radius * 2), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    position += velocity * dt;
    velocity *= 0.86;
    if (_timer >= lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_timer / lifetime).clamp(0.0, 1.0);
    final alpha = (0.5 * (1.0 - progress)).clamp(0.0, 0.5);
    final paint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(radius, radius), radius * (1.0 + progress * 0.6), paint);
  }
}

class ZombieCorpse extends PositionComponent with HasGameReference<ZombieGame> {
  final double facingAngle;
  final Vector2 fatalDir;
  final double radius;
  final Color skinColor;
  final Color clothesColor;
  final bool isRunner;
  final double lifetime = 5.0;
  double _timer = 0.0;
  double _bloodPoolRadius = 0.0;
  final double _maxBloodPoolRadius;

  ZombieCorpse({
    required Vector2 position,
    required this.facingAngle,
    required this.fatalDir,
    required this.radius,
    required this.skinColor,
    required this.clothesColor,
    this.isRunner = false,
  })  : _maxBloodPoolRadius = radius * (isRunner ? 2.0 : 1.6),
        super(
          position: position,
          size: Vector2.all(radius * 4.6),
          anchor: Anchor.center,
          priority: -1, // Render on ground under living zombies
        );

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    // Expand blood pool over first 1.2 seconds
    if (_timer <= 1.2) {
      _bloodPoolRadius = (_timer / 1.2) * _maxBloodPoolRadius;
    }

    // Decay and remove after lifetime
    if (_timer >= lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final opacity = (_timer > 3.5 ? (1.0 - ((_timer - 3.5) / 1.5)) : 1.0).clamp(0.0, 1.0);
    final center = Offset(size.x / 2, size.y / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(facingAngle);

    // 1. Draw Expanding Blood Pool or Runner Skid Mark on Floor
    if (_bloodPoolRadius > 0) {
      final poolPaint = Paint()
        ..color = const Color(0xFF5C0606).withValues(alpha: 0.88 * opacity)
        ..style = PaintingStyle.fill;
      final bloodEdgePaint = Paint()
        ..color = const Color(0xFF330000).withValues(alpha: 0.92 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      if (isRunner) {
        // Fast Runner High-Speed Blood Skid Streak with Asphalt Friction Burns
        final skidLength = _bloodPoolRadius * 3.2;

        // Dark Asphalt friction burn base
        final burnPaint = Paint()
          ..color = const Color(0xFF140707).withValues(alpha: 0.82 * opacity)
          ..style = PaintingStyle.fill;
        final burnRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(-skidLength * 0.15, 0),
            width: skidLength * 1.1,
            height: radius * 1.6,
          ),
          const Radius.circular(8.0),
        );
        canvas.drawRRect(burnRect, burnPaint);

        // Crimson Blood Skid Layer
        final skidRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(-skidLength * 0.1, 0),
            width: skidLength,
            height: radius * 1.3,
          ),
          const Radius.circular(6.0),
        );
        canvas.drawRRect(skidRect, poolPaint);

        // Asphalt claw scratch gouges
        final scratchPaint = Paint()
          ..color = const Color(0xFF8B0000).withValues(alpha: 0.9 * opacity)
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(-skidLength * 0.65, -radius * 0.45), Offset(skidLength * 0.35, -radius * 0.3), scratchPaint);
        canvas.drawLine(Offset(-skidLength * 0.75, 0), Offset(skidLength * 0.45, 0), scratchPaint);
        canvas.drawLine(Offset(-skidLength * 0.65, radius * 0.45), Offset(skidLength * 0.35, radius * 0.3), scratchPaint);

        // Flying blood spatters along skid edges
        final speckPaint = Paint()..color = const Color(0xFF7F0000).withValues(alpha: 0.8 * opacity);
        canvas.drawCircle(Offset(-skidLength * 0.4, -radius * 0.7), 2.2, speckPaint);
        canvas.drawCircle(Offset(-skidLength * 0.2, radius * 0.7), 2.5, speckPaint);
        canvas.drawCircle(Offset(skidLength * 0.2, -radius * 0.65), 1.8, speckPaint);
      } else {
        // Circular / Oval Pool for other zombies
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(fatalDir.x * 6, fatalDir.y * 6),
            width: _bloodPoolRadius * 2.2,
            height: _bloodPoolRadius * 1.6,
          ),
          poolPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(fatalDir.x * 6, fatalDir.y * 6),
            width: _bloodPoolRadius * 2.2,
            height: _bloodPoolRadius * 1.6,
          ),
          bloodEdgePaint,
        );
      }
    }

    // 2. Draw Collapsed Zombie Corpse
    final fallProgress = (_timer / 0.35).clamp(0.0, 1.0);
    // Runners slide forward with sprint momentum; walkers recoil backwards with bullet momentum
    final slideOffset = isRunner ? (fallProgress * radius * 1.1) : (-fallProgress * radius * 0.6);

    final bodyPaint = Paint()..color = clothesColor.withValues(alpha: opacity);
    final skinPaint = Paint()..color = skinColor.withValues(alpha: opacity);
    final bloodStainPaint = Paint()..color = const Color(0xFF8B0000).withValues(alpha: 0.92 * opacity);

    if (isRunner) {
      // Fast Runner collapsed athletic corpse: facedown, hunched spine, splayed claws
      final runnerTorsoPath = Path()
        ..moveTo(slideOffset + radius * 0.7, 0)
        ..lineTo(slideOffset - radius * 0.8, -radius * 0.5)
        ..lineTo(slideOffset - radius * 1.0, 0)
        ..lineTo(slideOffset - radius * 0.8, radius * 0.5)
        ..close();
      canvas.drawPath(runnerTorsoPath, bodyPaint);

      // Exposed broken vertebrae on back of corpse
      final bonePaint = Paint()..color = const Color(0xFFE8E8A6).withValues(alpha: opacity);
      for (int i = 0; i < 4; i++) {
        canvas.drawCircle(Offset(slideOffset - radius * 0.2 - (i * radius * 0.2), 0), 1.6, bonePaint);
      }

      // Torn hoodie shreds
      final shredPaint = Paint()..color = const Color(0xFF1B0505).withValues(alpha: opacity);
      canvas.drawCircle(Offset(slideOffset - radius * 0.4, -radius * 0.3), radius * 0.22, shredPaint);
      canvas.drawCircle(Offset(slideOffset - radius * 0.3, radius * 0.3), radius * 0.2, shredPaint);

      // Heavy blood staining across runner back
      canvas.drawCircle(Offset(slideOffset - 2, 0), radius * 0.35, bloodStainPaint);
      canvas.drawCircle(Offset(slideOffset + 4, -2), radius * 0.25, bloodStainPaint);

      // Fallen Runner Head slumped facedown
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(slideOffset + radius * 0.85, 0),
          width: radius * 1.0,
          height: radius * 0.75,
        ),
        skinPaint,
      );
      // Head fatal shot wound
      canvas.drawCircle(
        Offset(slideOffset + radius * 0.95, -2),
        radius * 0.32,
        bloodStainPaint,
      );

      // Extended Razor Claws sprawled out forward on pavement
      final armPaint = Paint()
        ..color = skinColor.withValues(alpha: opacity)
        ..strokeWidth = radius * 0.26
        ..strokeCap = StrokeCap.round;
      final clawPaint = Paint()
        ..color = const Color(0xFFFF1744).withValues(alpha: opacity)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;

      // Left claw sprawled forward
      canvas.drawLine(
        Offset(slideOffset, -radius * 0.45),
        Offset(slideOffset + radius * 1.3, -radius * 0.7),
        armPaint,
      );
      canvas.drawLine(Offset(slideOffset + radius * 1.3, -radius * 0.7), Offset(slideOffset + radius * 1.7, -radius * 0.9), clawPaint);
      canvas.drawLine(Offset(slideOffset + radius * 1.3, -radius * 0.7), Offset(slideOffset + radius * 1.8, -radius * 0.7), clawPaint);

      // Right claw sprawled forward
      canvas.drawLine(
        Offset(slideOffset, radius * 0.45),
        Offset(slideOffset + radius * 1.35, radius * 0.7),
        armPaint,
      );
      canvas.drawLine(Offset(slideOffset + radius * 1.35, radius * 0.7), Offset(slideOffset + radius * 1.75, radius * 0.9), clawPaint);
      canvas.drawLine(Offset(slideOffset + radius * 1.35, radius * 0.7), Offset(slideOffset + radius * 1.85, radius * 0.7), clawPaint);
    } else {
      // Walkers / Normal Zombie Corpse
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(slideOffset, 0),
          width: radius * 1.8,
          height: radius * 1.3,
        ),
        bodyPaint,
      );

      // Blood splatters across torso
      canvas.drawCircle(Offset(slideOffset - 2, -3), radius * 0.3, bloodStainPaint);
      canvas.drawCircle(Offset(slideOffset + 4, 2), radius * 0.25, bloodStainPaint);

      // Fallen Head tilted sideways
      canvas.drawCircle(
        Offset(slideOffset + radius * 0.7, 4),
        radius * 0.75,
        skinPaint,
      );

      // Head fatal wound
      canvas.drawCircle(
        Offset(slideOffset + radius * 0.8, 6),
        radius * 0.35,
        bloodStainPaint,
      );

      // Splayed limp arms
      final armPaint = Paint()
        ..color = skinColor.withValues(alpha: opacity)
        ..strokeWidth = radius * 0.35
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(slideOffset, -radius * 0.6),
        Offset(slideOffset - radius * 0.8, -radius * 1.1),
        armPaint,
      );
      canvas.drawLine(
        Offset(slideOffset, radius * 0.6),
        Offset(slideOffset - radius * 0.4, radius * 1.2),
        armPaint,
      );
    }

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

  static void runnerSpeedTrail(ZombieGame game, Vector2 pos, Vector2 dir, double facingAngle, double radius) {
    final rng = Random();
    // 1. Red speed blur particle
    final trailPos = pos - dir.normalized() * 14.0 + Vector2((rng.nextDouble() - 0.5) * 6, (rng.nextDouble() - 0.5) * 6);
    game.world.add(
      SpeedTrailParticle(
        position: trailPos,
        color: const Color(0xFFD32F2F),
        radius: 4.5 + rng.nextDouble() * 3.0,
      ),
    );

    // 2. Translucent ghost silhouette afterimage
    game.world.add(
      RunnerGhostAfterimage(
        position: pos.clone(),
        facingAngle: facingAngle,
        radius: radius,
      ),
    );
  }

  static void runnerSprintDust(ZombieGame game, Vector2 pos, Vector2 dir) {
    final rng = Random();
    final backDir = -dir.normalized();
    for (int i = 0; i < 2; i++) {
      final spreadAngle = atan2(backDir.y, backDir.x) + (rng.nextDouble() - 0.5) * 1.0;
      final dustVel = Vector2(cos(spreadAngle), sin(spreadAngle)) * (30.0 + rng.nextDouble() * 40.0);
      game.world.add(
        RunnerGroundDust(
          position: pos + backDir * 8.0 + Vector2((rng.nextDouble() - 0.5) * 4, (rng.nextDouble() - 0.5) * 4),
          velocity: dustVel,
          color: rng.nextBool() ? const Color(0xFF4E342E) : const Color(0xFF3E2723),
          radius: 2.0 + rng.nextDouble() * 2.0,
        ),
      );
    }
  }

  static void runnerPounceBurst(ZombieGame game, Vector2 pos, Vector2 dir) {
    final rng = Random();
    // Explosive leap trail & dust blast
    for (int i = 0; i < 6; i++) {
      final angle = atan2(-dir.y, -dir.x) + (rng.nextDouble() - 0.5) * 1.5;
      final speed = 60.0 + rng.nextDouble() * 90.0;
      final vel = Vector2(cos(angle), sin(angle)) * speed;
      game.world.add(
        RunnerGroundDust(
          position: pos.clone(),
          velocity: vel,
          color: const Color(0xFF5D4037),
          radius: 3.0 + rng.nextDouble() * 3.0,
          lifetime: 0.35,
        ),
      );
    }
    // High-speed speed flame ember
    for (int i = 0; i < 4; i++) {
      final angle = atan2(-dir.y, -dir.x) + (rng.nextDouble() - 0.5) * 0.8;
      final speed = 80.0 + rng.nextDouble() * 100.0;
      final vel = Vector2(cos(angle), sin(angle)) * speed;
      game.world.add(
        BloodParticle(
          position: pos.clone(),
          velocity: vel,
          color: const Color(0xFFFF1744),
          radius: 2.2,
          lifetime: 0.25,
        ),
      );
    }
  }

  static void runnerDeathBurst(ZombieGame game, Vector2 pos, Vector2 fatalDir) {
    final rng = Random();

    // 1. High Velocity Forward Blood Jet (24 particles shooting forward along momentum)
    for (int i = 0; i < 24; i++) {
      final angle = atan2(fatalDir.y, fatalDir.x) + (rng.nextDouble() - 0.5) * 1.2;
      final speed = 160.0 + rng.nextDouble() * 240.0;
      final vel = Vector2(cos(angle), sin(angle)) * speed;
      game.world.add(
        BloodParticle(
          position: pos.clone(),
          velocity: vel,
          color: i % 3 == 0
              ? const Color(0xFF4A0000)
              : (i % 2 == 0 ? const Color(0xFFB71C1C) : const Color(0xFFFF1744)),
          radius: 2.2 + rng.nextDouble() * 3.5,
          lifetime: 0.65 + rng.nextDouble() * 0.45,
        ),
      );
    }

    // 2. Flying Severed Razor Claws & Bone Shards (8-10 chunks spinning violently)
    for (int i = 0; i < 9; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 100.0 + rng.nextDouble() * 180.0;
      final vel = Vector2(cos(angle), sin(angle)) * speed;
      game.world.add(
        GoreChunkParticle(
          position: pos.clone(),
          velocity: vel,
          color: i % 3 == 0
              ? const Color(0xFFFF1744) // Bright red claw tip
              : (i % 2 == 0 ? const Color(0xFF8B1A1A) : const Color(0xFFE8E8A6)), // Muscle or bone
          radius: 2.5 + rng.nextDouble() * 3.0,
          lifetime: 0.7 + rng.nextDouble() * 0.5,
          rotSpeed: (rng.nextDouble() - 0.5) * 24.0,
        ),
      );
    }

    // 3. Ground Dust blast from high speed impact
    for (int i = 0; i < 5; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 40.0 + rng.nextDouble() * 60.0;
      final vel = Vector2(cos(angle), sin(angle)) * speed;
      game.world.add(
        RunnerGroundDust(
          position: pos.clone(),
          velocity: vel,
          color: const Color(0xFF3E2723),
          radius: 3.5 + rng.nextDouble() * 2.5,
        ),
      );
    }
  }

  static void zombieDeathBurst(ZombieGame game, Vector2 pos, Vector2 fatalDir, {double scale = 1.0}) {
    final rng = Random();

    // 1. Blood Spray Particles (12-16 particles)
    for (int i = 0; i < (14 * scale).toInt(); i++) {
      final angle = atan2(fatalDir.y, fatalDir.x) + (rng.nextDouble() - 0.5) * 2.0;
      final speed = (90.0 + rng.nextDouble() * 180.0) * scale;
      final vel = Vector2(cos(angle), sin(angle)) * speed;
      game.world.add(
        BloodParticle(
          position: pos.clone(),
          velocity: vel,
          color: i % 3 == 0
              ? const Color(0xFF4A0000)
              : (i % 2 == 0 ? const Color(0xFF8B0000) : const Color(0xFFD32F2F)),
          radius: (2.5 + rng.nextDouble() * 3.5) * scale,
          lifetime: 0.5 + rng.nextDouble() * 0.5,
        ),
      );
    }

    // 2. Flesh / Skull Gore Chunks (5-7 chunks flying out)
    for (int i = 0; i < (6 * scale).toInt(); i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = (60.0 + rng.nextDouble() * 140.0) * scale;
      final vel = Vector2(cos(angle), sin(angle)) * speed;
      game.world.add(
        GoreChunkParticle(
          position: pos.clone(),
          velocity: vel,
          color: i % 2 == 0 ? const Color(0xFF5C0606) : const Color(0xFF385836),
          radius: (3.0 + rng.nextDouble() * 3.0) * scale,
          lifetime: 0.7 + rng.nextDouble() * 0.6,
          rotSpeed: (rng.nextDouble() - 0.5) * 12.0,
        ),
      );
    }
  }
}
