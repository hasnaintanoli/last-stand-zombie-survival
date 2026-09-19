import 'weapon.dart';

class Pistol extends Weapon {
  Pistol()
      : super(
          name: 'Pistol',
          type: WeaponType.pistol,
          damage: 28.0,
          fireRate: 0.32,
          magSize: 12,
          currentMagAmmo: 12,
          reserveAmmo: 9999, // Infinite reserve ammo for pistol
          reloadTime: 1.2,
          bulletSpeed: 750.0,
          range: 550.0,
          pelletCount: 1,
          spreadAngle: 0.05,
        );
}
