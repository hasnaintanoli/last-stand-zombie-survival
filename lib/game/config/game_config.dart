import 'package:flutter/material.dart';

class GameConfig {
  // Map dimensions
  static const double mapWidth = 2400.0;
  static const double mapHeight = 2400.0;

  // Player defaults
  static const double playerBaseSpeed = 190.0;
  static const double playerBaseHealth = 100.0;
  static const double playerSize = 36.0;

  // Colors - Dark Cinematic Zombie Theme
  static const Color darkBg = Color(0xFF0F1115);
  static const Color asphaltColor = Color(0xFF181B20);
  static const Color roadLineColor = Color(0xFF333842);
  static const Color accentRed = Color(0xFFE53935);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentGold = Color(0xFFFFB300);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentPurple = Color(0xFFD500F9);
  static const Color cardBg = Color(0xFF1E222A);
  static const Color hudText = Color(0xFFEEEEEE);

  // Upgrade Options
  static const List<Map<String, dynamic>> upgradePool = [
    {
      'id': 'damage',
      'title': '+20% Damage',
      'desc': 'Increases weapon damage per bullet.',
      'icon': Icons.bolt,
      'color': Colors.amber,
    },
    {
      'id': 'speed',
      'title': '+15% Speed',
      'desc': 'Increases player movement speed.',
      'icon': Icons.directions_run,
      'color': Colors.blue,
    },
    {
      'id': 'max_health',
      'title': '+25 Max HP',
      'desc': 'Increases maximum health & heals 25 HP.',
      'icon': Icons.favorite,
      'color': Colors.redAccent,
    },
    {
      'id': 'rapid_fire',
      'title': '+20% Fire Rate',
      'desc': 'Reduces delay between consecutive shots.',
      'icon': Icons.speed,
      'color': Colors.orangeAccent,
    },
    {
      'id': 'extended_mag',
      'title': '+30% Ammo Capacity',
      'desc': 'Enlarges magazine capacity for all guns.',
      'icon': Icons.grid_view,
      'color': Colors.purpleAccent,
    },
    {
      'id': 'magnet',
      'title': '+50% Magnet Range',
      'desc': 'Draws health, ammo, and coins from further away.',
      'icon': Icons.center_focus_strong,
      'color': Colors.tealAccent,
    },
    {
      'id': 'vampire',
      'title': 'Vampirism',
      'desc': 'Restores 2 HP for every zombie killed.',
      'icon': Icons.bloodtype,
      'color': Colors.deepOrangeAccent,
    },
  ];
}
