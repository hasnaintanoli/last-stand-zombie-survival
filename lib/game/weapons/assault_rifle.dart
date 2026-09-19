import 'weapon.dart';

class AssaultRifle extends Weapon {
  AssaultRifle()
      : super(
          name: 'Assault Rifle',
          type: WeaponType.assaultRifle,
          damage: 16.0,
          fireRate: 0.1, // Rapid fire!
          magSize: 30,
          currentMagAmmo: 30,
          reserveAmmo: 180,
          reloadTime: 1.8,
          bulletSpeed: 850.0,
          range: 650.0,
          pelletCount: 1,
          spreadAngle: 0.08,
        );
}
