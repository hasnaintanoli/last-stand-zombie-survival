enum WeaponType { pistol, shotgun, assaultRifle }

abstract class Weapon {
  final String name;
  final WeaponType type;
  double damage;
  double fireRate; // Seconds between shots
  int magSize;
  int currentMagAmmo;
  int reserveAmmo;
  double reloadTime;
  double bulletSpeed;
  double range;
  int pelletCount;
  double spreadAngle;

  double _cooldownTimer = 0.0;
  bool isReloading = false;
  double _reloadTimer = 0.0;

  Weapon({
    required this.name,
    required this.type,
    required this.damage,
    required this.fireRate,
    required this.magSize,
    required this.currentMagAmmo,
    required this.reserveAmmo,
    required this.reloadTime,
    required this.bulletSpeed,
    required this.range,
    this.pelletCount = 1,
    this.spreadAngle = 0.0,
  });

  bool get canShoot => _cooldownTimer <= 0 && !isReloading && currentMagAmmo > 0;

  void update(double dt) {
    if (_cooldownTimer > 0) {
      _cooldownTimer -= dt;
    }
    if (isReloading) {
      _reloadTimer -= dt;
      if (_reloadTimer <= 0) {
        isReloading = false;
        _finishReload();
      }
    }
  }

  void shoot() {
    if (!canShoot) return;
    currentMagAmmo--;
    _cooldownTimer = fireRate;
    if (currentMagAmmo == 0 && reserveAmmo > 0) {
      startReload();
    }
  }

  void startReload() {
    if (isReloading || currentMagAmmo == magSize || reserveAmmo <= 0) return;
    isReloading = true;
    _reloadTimer = reloadTime;
  }

  void _finishReload() {
    final needed = magSize - currentMagAmmo;
    if (reserveAmmo >= needed) {
      currentMagAmmo += needed;
      reserveAmmo -= needed;
    } else {
      currentMagAmmo += reserveAmmo;
      reserveAmmo = 0;
    }
  }

  void addAmmo(int amount) {
    reserveAmmo += amount;
  }
}
