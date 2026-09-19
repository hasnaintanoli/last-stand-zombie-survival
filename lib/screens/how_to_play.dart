import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E222A),
        title: Text(
          'HOW TO PLAY',
          style: GoogleFonts.blackOpsOne(
            fontSize: 24,
            color: const Color(0xFFE53935),
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('PLAYER CONTROLS'),
            const SizedBox(height: 12),
            _card(
              title: 'Mobile Touch Controls',
              icon: Icons.smartphone,
              color: Colors.blueAccent,
              content: [
                '• Left Joystick: Move survivor in 360 degrees',
                '• Shoot Button: Continuous fire weapon',
                '• Reload Button: Manual magazine reload',
                '• Weapon Switcher: Switch between Pistol, Shotgun, and Assault Rifle',
              ],
            ),
            const SizedBox(height: 12),
            _card(
              title: 'Desktop PC Controls',
              icon: Icons.computer,
              color: Colors.tealAccent,
              content: [
                '• WASD / Arrow Keys: Move survivor',
                '• Mouse Cursor: Aim direction vector',
                '• Left Mouse Button: Fire weapon',
                '• Key R: Reload magazine',
                '• Keys 1, 2, 3: Switch weapons',
              ],
            ),

            const SizedBox(height: 28),
            _sectionHeader('ZOMBIE THREATS'),
            const SizedBox(height: 12),
            _card(
              title: 'Normal Zombie (Green)',
              icon: Icons.bug_report,
              color: Colors.green,
              content: ['Slow movement, low health. Spawns in groups.'],
            ),
            const SizedBox(height: 8),
            _card(
              title: 'Fast Zombie (Crimson)',
              icon: Icons.bolt,
              color: Colors.redAccent,
              content: ['Sprint movement, low health. Flanks quickly!'],
            ),
            const SizedBox(height: 8),
            _card(
              title: 'Tank Zombie (Dark Purple)',
              icon: Icons.security,
              color: Colors.indigo,
              content: ['Massive health & armor. High melee damage.'],
            ),
            const SizedBox(height: 8),
            _card(
              title: 'Boss Zombie (Spiked Aura)',
              icon: Icons.dangerous,
              color: Colors.purpleAccent,
              content: [
                'Spawns every 5th wave! Huge health bar, drops 2x Damage Powerup & 1,000 Score.'
              ],
            ),

            const SizedBox(height: 28),
            _sectionHeader('PICKUPS & POWER-UPS'),
            const SizedBox(height: 12),
            _card(
              title: 'Field Supplies',
              icon: Icons.card_giftcard,
              color: Colors.amber,
              content: [
                '💚 Health Crate: Heals +35 HP',
                '⚡ Ammo Box: Refills clip & reserve ammo',
                '🪙 Gold Coin: Earns +10 currency',
                '🟣 2X Damage: Grants double weapon damage for 10 seconds',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.orbitron(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFE53935),
        letterSpacing: 3.0,
      ),
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333842)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.orbitron(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...content.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                line,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
