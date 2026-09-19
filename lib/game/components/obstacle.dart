import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../zombie_game.dart';

enum ObstacleType { car, barrier, crate, lightPole, tree }

class Obstacle extends PositionComponent with HasGameReference<ZombieGame> {
  final ObstacleType type;

  Obstacle({
    required Vector2 position,
    required Vector2 size,
    required this.type,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  bool containsPoint(Vector2 point) {
    // Circle or rectangle check
    if (type == ObstacleType.tree || type == ObstacleType.lightPole) {
      final radius = size.x / 2;
      return (point - position).length <= radius;
    } else {
      final halfW = size.x / 2;
      final halfH = size.y / 2;
      return point.x >= position.x - halfW &&
          point.x <= position.x + halfW &&
          point.y >= position.y - halfH &&
          point.y <= position.y + halfH;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    switch (type) {
      case ObstacleType.car:
        _renderCar(canvas, rect);
        break;
      case ObstacleType.barrier:
        _renderBarrier(canvas, rect);
        break;
      case ObstacleType.crate:
        _renderCrate(canvas, rect);
        break;
      case ObstacleType.lightPole:
        _renderLightPole(canvas, rect);
        break;
      case ObstacleType.tree:
        _renderTree(canvas, rect);
        break;
    }
  }

  void _renderCar(Canvas canvas, Rect rect) {
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            rect.translate(4, 4), const Radius.circular(8)),
        shadowPaint);

    final carPaint = Paint()..color = const Color(0xFF2C3539);
    final glassPaint = Paint()..color = const Color(0xFF4A6572);
    final lightPaint = Paint()..color = Colors.yellow.withValues(alpha: 0.8);

    // Car Body
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, carPaint);

    // Windshield
    final windshield = Rect.fromLTWH(
        rect.width * 0.2, rect.height * 0.25, rect.width * 0.6, rect.height * 0.2);
    canvas.drawRect(windshield, glassPaint);

    // Headlights
    canvas.drawCircle(Offset(rect.width * 0.2, 4), 3, lightPaint);
    canvas.drawCircle(Offset(rect.width * 0.8, 4), 3, lightPaint);
  }

  void _renderBarrier(Canvas canvas, Rect rect) {
    final barrierPaint = Paint()..color = const Color(0xFF757575);
    final stripePaint = Paint()..color = const Color(0xFFD32F2F);

    canvas.drawRect(rect, barrierPaint);
    // Warning Stripes
    final path = Path();
    for (double x = -rect.height; x < rect.width; x += 16) {
      path.moveTo(x, 0);
      path.lineTo(x + 8, 0);
      path.lineTo(x + 8 + rect.height, rect.height);
      path.lineTo(x + rect.height, rect.height);
      path.close();
    }
    canvas.save();
    canvas.clipRect(rect);
    canvas.drawPath(path, stripePaint);
    canvas.restore();
  }

  void _renderCrate(Canvas canvas, Rect rect) {
    final woodPaint = Paint()..color = const Color(0xFF8D6E63);
    final borderPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRect(rect, woodPaint);
    canvas.drawRect(rect, borderPaint);
    canvas.drawLine(
        rect.topLeft, rect.bottomRight, borderPaint);
    canvas.drawLine(
        rect.topRight, rect.bottomLeft, borderPaint);
  }

  void _renderLightPole(Canvas canvas, Rect rect) {
    final basePaint = Paint()..color = const Color(0xFF424242);
    final glowPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);

    // Light Glow
    canvas.drawCircle(
        Offset(rect.width / 2, rect.height / 2), rect.width * 1.5, glowPaint);
    // Pole Base
    canvas.drawCircle(
        Offset(rect.width / 2, rect.height / 2), rect.width / 2, basePaint);
  }

  void _renderTree(Canvas canvas, Rect rect) {
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.4);
    final foliagePaint = Paint()..color = const Color(0xFF1B5E20);
    final innerFoliage = Paint()..color = const Color(0xFF2E7D32);

    final center = Offset(rect.width / 2, rect.height / 2);
    final r = rect.width / 2;

    canvas.drawCircle(center + const Offset(4, 4), r, shadowPaint);
    canvas.drawCircle(center, r, foliagePaint);
    canvas.drawCircle(center - const Offset(3, 3), r * 0.7, innerFoliage);
  }
}
