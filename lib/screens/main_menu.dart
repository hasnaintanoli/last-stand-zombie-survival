import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../services/local_storage.dart';
import 'game_screen.dart';
import 'how_to_play.dart';
import 'settings.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int highScore = 0;
  int highestWave = 1;
  int totalKills = 0;
  int coins = 0;
  bool musicEnabled = LocalStorage.getMusicEnabled();
  bool soundEnabled = LocalStorage.getSoundEnabled();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      highScore = LocalStorage.getHighScore();
      highestWave = LocalStorage.getHighestWave();
      totalKills = LocalStorage.getTotalKills();
      coins = LocalStorage.getCoins();
      musicEnabled = LocalStorage.getMusicEnabled();
      soundEnabled = LocalStorage.getSoundEnabled();
    });
    if (musicEnabled) {
      AudioService().startBgm();
    } else {
      AudioService().stopBgm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Stack(
        children: [
          // Background Atmospheric Dark Glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.3),
                  radius: 1.1,
                  colors: [
                    Color(0xFF2C1417), // Subtle Dark Red Gore Tint
                    Color(0xFF0F1115),
                  ],
                ),
              ),
            ),
          ),

          // Top-Right Quick Audio & Music Controls
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sound FX Toggle
                  _quickAudioButton(
                    icon: soundEnabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    color: soundEnabled ? Colors.amber : Colors.grey.shade600,
                    tooltip: soundEnabled ? 'Sound FX: ON' : 'Sound FX: OFF',
                    onTap: () {
                      setState(() {
                        soundEnabled = !soundEnabled;
                        LocalStorage.setSoundEnabled(soundEnabled);
                        if (!soundEnabled) {
                          AudioService().stopFootstep();
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  // Music Toggle
                  _quickAudioButton(
                    icon: musicEnabled
                        ? Icons.music_note_rounded
                        : Icons.music_off_rounded,
                    color: musicEnabled
                        ? Colors.purpleAccent
                        : Colors.grey.shade600,
                    tooltip: musicEnabled ? 'Music: ON' : 'Music: OFF',
                    onTap: () {
                      setState(() {
                        musicEnabled = !musicEnabled;
                        LocalStorage.setMusicEnabled(musicEnabled);
                        if (musicEnabled) {
                          AudioService().startBgm();
                        } else {
                          AudioService().stopBgm();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game Logo Header Image
                  Image.asset(
                    'assets/images/logo.png',
                    width: 380,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),

                  // High Score / Stats Card
                  Container(
                    width: 380,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E222A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF333842),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statItem(
                              'HIGH SCORE',
                              highScore.toString(),
                              Icons.emoji_events,
                              Colors.amber,
                            ),
                            _statItem(
                              'BEST WAVE',
                              'WAVE $highestWave',
                              Icons.shield,
                              Colors.redAccent,
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFF333842), height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statItem(
                              'TOTAL KILLS',
                              totalKills.toString(),
                              Icons.dangerous,
                              Colors.orangeAccent,
                            ),
                            _statItem(
                              'COINS',
                              coins.toString(),
                              Icons.monetization_on,
                              Colors.yellow,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Main Menu Buttons
                  _menuButton(
                    context,
                    label: 'PLAY GAME',
                    icon: Icons.play_arrow_rounded,
                    color: const Color(0xFFE53935),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GameScreen()),
                      ).then((_) => _loadStats());
                    },
                  ),
                  const SizedBox(height: 16),

                  _menuButton(
                    context,
                    label: 'HOW TO PLAY',
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFF2E7D32),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HowToPlayScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  _menuButton(
                    context,
                    label: 'SETTINGS',
                    icon: Icons.settings_rounded,
                    color: const Color(0xFF1976D2),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ).then((_) => _loadStats());
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.orbitron(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _menuButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 320,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24, color: Colors.white),
        label: Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _quickAudioButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E222A).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF333842), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }
}
