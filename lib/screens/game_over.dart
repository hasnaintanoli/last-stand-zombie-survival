import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/zombie_game.dart';
import '../services/local_storage.dart';

class GameOverDialog extends StatelessWidget {
  final ZombieGame game;
  const GameOverDialog({super.key, required this.game});

  String _formatTime(double seconds) {
    final mins = (seconds / 60).floor().toString().padLeft(2, '0');
    final secs = (seconds % 60).floor().toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final isNewHighScore = game.player.score > LocalStorage.getHighScore();

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E222A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE53935), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 24,
                spreadRadius: 6,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GAME OVER',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 36,
                  color: const Color(0xFFE53935),
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'YOU SURVIVED THE HORDE AS LONG AS YOU COULD',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              if (isNewHighScore) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'NEW HIGH SCORE!',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Summary Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1115),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _statRow('SURVIVAL TIME', _formatTime(game.survivalTime)),
                    const Divider(color: Color(0xFF333842)),
                    _statRow('WAVE REACHED', 'WAVE ${game.waveManager.currentWave}'),
                    const Divider(color: Color(0xFF333842)),
                    _statRow('ZOMBIES KILLED', '${game.totalZombiesKilled}'),
                    const Divider(color: Color(0xFF333842)),
                    _statRow('FINAL SCORE', '${game.player.score}', isGold: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        game.overlays.remove('GameOverOverlay');
                        game.resetGame();
                      },
                      icon: const Icon(Icons.replay, color: Colors.white),
                      label: Text(
                        'AGAIN',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        game.saveStats();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.home, color: Colors.white),
                      label: Text(
                        'MENU',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF37474F),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, {bool isGold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isGold ? Colors.amberAccent : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
