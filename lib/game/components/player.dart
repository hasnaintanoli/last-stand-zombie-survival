import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../zombie_game.dart';
import '../weapons/weapon.dart';
import '../weapons/pistol.dart';
import '../weapons/shotgun.dart';
import '../weapons/assault_rifle.dart';
import 'bullet.dart';
import 'particle_effects.dart';

class Player extends PositionComponent with HasGameReference<ZombieGame> {
  double health = 100.0;
  double maxHealth = 100.0;
  double speed = 190.0;
  double damageMultiplier = 1.0;
  double reloadSpeedMultiplier = 1.0;
  double magnetMultiplier = 1.0;
  double vampireHealAmount = 0.0;

  int score = 0;
  int level = 1;
  int xp = 0;
  int xpToNextLevel = 100;
  int coins = 0;

  double damageBoostTimer = 0.0;

  final double radius = 18.0;
  bool get isAlive => health > 0;

  late List<Weapon> weapons;
  int currentWeaponIndex = 0;
  Weapon get currentWeapon => weapons[currentWeaponIndex];

  Vector2 moveDirection = Vector2.zero();
  Vector2 aimDirection = Vector2(1, 0);

  double _hitFlashTimer = 0.0;
  double _walkAnimTimer = 0.0;

  Player({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(36.0),
          anchor: Anchor.center,
        ) {
    weapons = [Pistol(), Shotgun(), AssaultRifle()];
  }

  void switchWeapon(int index) {
    if (index >= 0 && index < weapons.length) {
      currentWeaponIndex = index;
    }
  }

  void nextWeapon() {
    currentWeaponIndex = (currentWeaponIndex + 1) % weapons.length;
  }

  void updateInput({required Vector2 move, Vector2? aim}) {
    moveDirection = move;
    if (aim != null && aim.length > 0.1) {
      aimDirection = aim.normalized();
    } else if (move.length > 0.1) {
      aimDirection = move.normalized();
    }
  }

  void shoot() {
    if (!isAlive || !currentWeapon.canShoot) return;

    currentWeapon.shoot();
    final effectiveDamage = currentWeapon.damage *
        damageMultiplier *
        (damageBoostTimer > 0 ? 2.0 : 1.0);

    // Muzzle flash particle
    final muzzlePos = position + aimDirection * 22.0;
    game.world.add(
      MuzzleFlashEffect(
        position: muzzlePos,
        angleRad: atan2(aimDirection.y, aimDirection.x),
      ),
    );

    // Spawn Bullet(s) based on weapon pellet count & spread
    final baseAngle = atan2(aimDirection.y, aimDirection.x);
    final rng = Random();

    for (int i = 0; i < currentWeapon.pelletCount; i++) {
      double angle = baseAngle;
      if (currentWeapon.pelletCount > 1) {
        angle += (rng.nextDouble() - 0.5) * currentWeapon.spreadAngle;
      } else if (currentWeapon.spreadAngle > 0) {
        angle += (rng.nextDouble() - 0.5) * currentWeapon.spreadAngle;
      }
      final bulletDir = Vector2(cos(angle), sin(angle));

      game.world.add(
        Bullet(
          position: muzzlePos.clone(),
          direction: bulletDir,
          speed: currentWeapon.bulletSpeed,
          damage: effectiveDamage,
          maxRange: currentWeapon.range,
        ),
      );
    }

    // Play weapon-specific shooting audio effect
    switch (currentWeapon.type) {
      case WeaponType.pistol:
        game.audio.playPistolShoot();
        break;
      case WeaponType.shotgun:
        game.audio.playShotgunShoot();
        break;
      case WeaponType.assaultRifle:
        game.audio.playRifleShoot();
        break;
    }
  }


  void reload() {
    if (!isAlive) return;
    currentWeapon.startReload();
    game.audio.playReload();
  }

  void takeDamage(double amount) {
    if (!isAlive) return;
    health -= amount;
    _hitFlashTimer = 0.2;
    game.triggerScreenShake(0.2);

    if (health <= 0) {
      health = 0;
      game.audio.stopFootstep();
      game.onPlayerDeath();
    }
  }

  @override
  void onRemove() {
    game.audio.stopFootstep();
    super.onRemove();
  }

  void heal(double amount) {
    health = (health + amount).clamp(0.0, maxHealth);
  }

  void refillCurrentAmmo() {
    currentWeapon.addAmmo(currentWeapon.magSize * 3);
    currentWeapon.currentMagAmmo = currentWeapon.magSize;
  }

  void addCoins(int amount) {
    coins += amount;
  }

  void applyDamageBoost(double duration) {
    damageBoostTimer = duration;
  }

  void addXp(int amount) {
    xp += amount;
    if (xp >= xpToNextLevel) {
      xp -= xpToNextLevel;
      level++;
      xpToNextLevel = (xpToNextLevel * 1.35).toInt();
      game.onLevelUp();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isAlive) {
      game.audio.stopFootstep();
      return;
    }

    // Timers
    currentWeapon.update(dt);
    if (damageBoostTimer > 0) damageBoostTimer -= dt;
    if (_hitFlashTimer > 0) _hitFlashTimer -= dt;

    // Movement & Footsteps
    if (moveDirection.length > 0.05) {
      _walkAnimTimer += dt * 10.0;
      final moveVelocity = moveDirection * speed * dt;
      position += moveVelocity;

      // Start looping footstep sound when moving
      game.audio.startFootstep();

      // Obstacle collision response
      for (final obstacle in game.obstacles) {
        if (obstacle.containsPoint(position)) {
          final pushDir = (position - obstacle.position).normalized();
          position += pushDir * (speed * dt * 1.2);
        }
      }
    } else {
      // Immediately stop footstep sound when stopped
      game.audio.stopFootstep();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset(size.x / 2, size.y / 2);
    final aimAngle = atan2(aimDirection.y, aimDirection.x);

    // Drop Shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    canvas.drawOval(
      Rect.fromCenter(
          center: center + const Offset(0, 14), width: 28, height: 12),
      shadowPaint,
    );

    // Damage Boost Aura
    if (damageBoostTimer > 0) {
      final boostPaint = Paint()
        ..color = Colors.purpleAccent.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
      canvas.drawCircle(center, radius * 1.5, boostPaint);
    }

    // Survivor Body
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(aimAngle);

    // Walk animation leg offset
    final legWobble = sin(_walkAnimTimer) * 4.0;

    // Boots / Feet
    final bootPaint = Paint()..color = const Color(0xFF263238);
    canvas.drawRect(Rect.fromLTWH(-6, -14 + legWobble, 8, 6), bootPaint);
    canvas.drawRect(Rect.fromLTWH(-6, 8 - legWobble, 8, 6), bootPaint);

    // Tactical Jacket
    Paint jacketPaint;
    if (_hitFlashTimer > 0) {
      jacketPaint = Paint()..color = Colors.redAccent;
    } else {
      jacketPaint = Paint()..color = const Color(0xFF3E2723); // Dark Brown Vest
    }
    canvas.drawCircle(Offset.zero, radius, jacketPaint);

    // Helmet / Cap
    final capPaint = Paint()..color = const Color(0xFF1B5E20); // Dark Camo
    canvas.drawCircle(const Offset(-2, 0), radius * 0.65, capPaint);

    // Arms & Weapon Model
    final armPaint = Paint()..color = const Color(0xFFD7CCC8); // Skin tone
    canvas.drawCircle(const Offset(6, -10), 4, armPaint);
    canvas.drawCircle(const Offset(12, 6), 4, armPaint);

    // Weapon Graphic
    final gunPaint = Paint()..color = const Color(0xFF212121);
    final metalPaint = Paint()..color = const Color(0xFF78909C);

    switch (currentWeapon.type) {
      case WeaponType.pistol:
        canvas.drawRect(const Rect.fromLTWH(8, 2, 14, 5), gunPaint);
        break;
      case WeaponType.shotgun:
        canvas.drawRect(const Rect.fromLTWH(6, 2, 22, 6), gunPaint);
        canvas.drawRect(const Rect.fromLTWH(18, 1, 10, 3), metalPaint);
        break;
      case WeaponType.assaultRifle:
        canvas.drawRect(const Rect.fromLTWH(6, 2, 26, 7), gunPaint);
        canvas.drawRect(const Rect.fromLTWH(14, 9, 4, 8), gunPaint); // Mag
        break;
    }

    canvas.restore();

    // Floating Health Bar above player head
    final barW = 34.0;
    final barH = 5.0;
    final barRect = Rect.fromCenter(
      center: center - const Offset(0, 26),
      width: barW,
      height: barH,
    );
    final bgBar = Paint()..color = const Color(0xCC000000);
    canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(3)), bgBar);

    final hpPercent = (health / maxHealth).clamp(0.0, 1.0);
    final hpColor = hpPercent > 0.5
        ? Colors.greenAccent
        : (hpPercent > 0.25 ? Colors.amberAccent : Colors.redAccent);
    final hpPaint = Paint()..color = hpColor;

    final fillRect = Rect.fromLTWH(
      barRect.left,
      barRect.top,
      barW * hpPercent,
      barH,
    );
    canvas.drawRRect(
        RRect.fromRectAndRadius(fillRect, const Radius.circular(3)), hpPaint);
  }
}
