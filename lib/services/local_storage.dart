import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // High Score
  static int getHighScore() {
    return _prefs?.getInt('highest_score') ?? 0;
  }

  static Future<bool> saveHighScore(int score) async {
    final current = getHighScore();
    if (score > current && _prefs != null) {
      return await _prefs!.setInt('highest_score', score);
    }
    return false;
  }

  // Highest Wave
  static int getHighestWave() {
    return _prefs?.getInt('highest_wave') ?? 1;
  }

  static Future<bool> saveHighestWave(int wave) async {
    final current = getHighestWave();
    if (wave > current && _prefs != null) {
      return await _prefs!.setInt('highest_wave', wave);
    }
    return false;
  }

  // Total Kills
  static int getTotalKills() {
    return _prefs?.getInt('total_kills') ?? 0;
  }

  static Future<void> addKills(int kills) async {
    final current = getTotalKills();
    if (_prefs != null) {
      await _prefs!.setInt('total_kills', current + kills);
    }
  }

  // Coins
  static int getCoins() {
    return _prefs?.getInt('total_coins') ?? 0;
  }

  static Future<void> addCoins(int amount) async {
    final current = getCoins();
    if (_prefs != null) {
      await _prefs!.setInt('total_coins', current + amount);
    }
  }

  // Audio Settings
  static bool getSoundEnabled() {
    return _prefs?.getBool('sound_enabled') ?? true;
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    if (_prefs != null) {
      await _prefs!.setBool('sound_enabled', enabled);
    }
  }

  static bool getMusicEnabled() {
    return _prefs?.getBool('music_enabled') ?? true;
  }

  static Future<void> setMusicEnabled(bool enabled) async {
    if (_prefs != null) {
      await _prefs!.setBool('music_enabled', enabled);
    }
  }
}
