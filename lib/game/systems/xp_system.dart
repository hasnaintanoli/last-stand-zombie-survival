import 'dart:math';
import '../config/game_config.dart';
import '../components/player.dart';

class XpSystem {
  static List<Map<String, dynamic>> getRandomUpgrades() {
    final pool = List<Map<String, dynamic>>.from(GameConfig.upgradePool);
    pool.shuffle(Random());
    return pool.take(3).toList();
  }

  static void applyUpgrade(Player player, String upgradeId) {
    switch (upgradeId) {
      case 'damage':
        player.damageMultiplier += 0.20;
        break;
      case 'speed':
        player.speed += 28.0;
        break;
      case 'max_health':
        player.maxHealth += 25.0;
        player.heal(25.0);
        break;
      case 'rapid_fire':
        for (final w in player.weapons) {
          w.fireRate *= 0.82;
        }
        break;
      case 'extended_mag':
        for (final w in player.weapons) {
          w.magSize = (w.magSize * 1.30).ceil();
        }
        break;
      case 'magnet':
        player.magnetMultiplier += 0.50;
        break;
      case 'vampire':
        player.vampireHealAmount += 2.0;
        break;
    }
  }
}
