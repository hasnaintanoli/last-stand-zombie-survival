import 'weapon.dart';

class Shotgun extends Weapon {
  Shotgun()
      : super(
          name: 'Shotgun',
          type: WeaponType.shotgun,
          damage: 18.0, // per pellet (5 pellets = 90 total max damage!)
          fireRate: 0.85,
          magSize: 8,
          currentMagAmmo: 8,
          reserveAmmo: 48,
          reloadTime: 2.2,
          bulletSpeed: 650.0,
          range: 380.0,
          pelletCount: 5,
          spreadAngle: 0.28, // Spread angle in radians (~16 degrees)
        );
}
