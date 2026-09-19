import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/zombie_game.dart';
import '../services/local_storage.dart';

class PauseMenuDialog extends StatefulWidget {
  final ZombieGame game;
  const PauseMenuDialog({super.key, required this.game});

  @override
  State<PauseMenuDialog> createState() => _PauseMenuDialogState();
}

class _PauseMenuDialogState extends State<PauseMenuDialog> {
  bool soundEnabled = LocalStorage.getSoundEnabled();
  bool musicEnabled = LocalStorage.getMusicEnabled();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E222A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF333842), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 20,
                spreadRadius: 4,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PAUSED',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 32,
                  color: Colors.white,
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 20),

              // Audio Controls
              SwitchListTile(
                title: Text(
                  'Sound FX',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                secondary: const Icon(Icons.volume_up, color: Colors.amber),
                value: soundEnabled,
                activeThumbColor: Colors.redAccent,
                onChanged: (val) {
                  setState(() {
                    soundEnabled = val;
                    LocalStorage.setSoundEnabled(val);
                  });
                },
              ),
              SwitchListTile(
                title: Text(
                  'Music',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                secondary: const Icon(Icons.music_note, color: Colors.purpleAccent),
                value: musicEnabled,
                activeThumbColor: Colors.redAccent,
                onChanged: (val) {
                  setState(() {
                    musicEnabled = val;
                    LocalStorage.setMusicEnabled(val);
                  });
                },
              ),
              const SizedBox(height: 24),

              // Resume Button
              _btn(
                label: 'RESUME',
                icon: Icons.play_arrow,
                color: Colors.green,
                onTap: () {
                  widget.game.overlays.remove('PauseOverlay');
                  widget.game.resumeEngine();
                },
              ),
              const SizedBox(height: 12),

              // Restart Button
              _btn(
                label: 'RESTART',
                icon: Icons.refresh,
                color: Colors.amber.shade800,
                onTap: () {
                  widget.game.overlays.remove('PauseOverlay');
                  widget.game.resetGame();
                },
              ),
              const SizedBox(height: 12),

              // Main Menu Button
              _btn(
                label: 'MAIN MENU',
                icon: Icons.home,
                color: Colors.redAccent,
                onTap: () {
                  widget.game.saveStats();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
