import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/zombie_game.dart';

class LevelUpDialog extends StatelessWidget {
  final ZombieGame game;
  const LevelUpDialog({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E222A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.amberAccent,
                blurRadius: 16,
                spreadRadius: 1,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LEVEL UP!',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 32,
                  color: Colors.amber,
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'CHOOSE A SURVIVAL UPGRADE',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Render the 3 upgrades
              ...game.pendingUpgrades.map((upgrade) {
                return _upgradeCard(
                  title: upgrade['title'],
                  desc: upgrade['desc'],
                  icon: upgrade['icon'],
                  color: upgrade['color'],
                  onTap: () {
                    game.selectUpgrade(upgrade['id']);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _upgradeCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1115),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.orbitron(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }
}
