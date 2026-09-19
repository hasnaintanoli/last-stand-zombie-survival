import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/zombie_game.dart';
import '../game/components/player.dart';
import '../game/systems/wave_manager.dart';
import '../game/weapons/weapon.dart';
import 'pause_menu.dart';
import 'level_up_dialog.dart';
import 'game_over.dart';


class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ZombieGame _game;
  late final Stream<int> _hudStream;

  // Joystick touch state
  Offset? _joystickCenter;
  Offset _joystickThumb = Offset.zero;

  @override
  void initState() {
    super.initState();
    _game = ZombieGame();
    _hudStream = Stream.periodic(const Duration(milliseconds: 33), (i) => i).asBroadcastStream();
  }

  @override
  void dispose() {
    _game.audio.stopFootstep();
    _game.saveStats();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Stack(
        children: [
          // Main Flame Game Canvas
          GameWidget<ZombieGame>(
            game: _game,
            overlayBuilderMap: {
              'PauseOverlay': (context, game) => PauseMenuDialog(game: game),
              'LevelUpOverlay': (context, game) => LevelUpDialog(game: game),
              'GameOverOverlay': (context, game) => GameOverDialog(game: game),
            },
          ),

          // Realtime 60 FPS HUD State Refresh Overlay
          StreamBuilder<int>(
            stream: _hudStream,
            builder: (context, snapshot) {
              return _buildHudOverlay();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHudOverlay() {
    if (!_game.isLoaded || !_game.player.isMounted) {
      return const SizedBox.shrink();
    }

    final player = _game.player;
    final waveMgr = _game.waveManager;
    final currentWeapon = player.currentWeapon;

    return SafeArea(
      child: Stack(
        children: [
          // Top HUD Row (Health, Wave, Score, Pause)
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top-Left: Health Bar
                _buildHealthBar(player),

                // Top-Center: Wave Badge
                _buildWaveBadge(waveMgr),

                // Top-Right: Score, Coins & Pause Button
                Row(
                  children: [
                    _buildScoreCoins(player),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.pause_circle_filled_rounded,
                          color: Colors.white, size: 36),
                      onPressed: () {
                        _game.audio.stopFootstep();
                        _game.overlays.add('PauseOverlay');
                        _game.pauseEngine();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Wave Announcement Banner (Middle of Screen)
          if (_game.waveBannerText != null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE53935), width: 2),
                ),
                child: Text(
                  _game.waveBannerText!,
                  style: GoogleFonts.blackOpsOne(
                    fontSize: 28,
                    color: const Color(0xFFE53935),
                    letterSpacing: 3.0,
                  ),
                ),
              ),
            ),

          // Bottom Bar (XP & Ammo Status)
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Bottom-Left: Virtual Movement Joystick Zone (Touch target)
                _buildVirtualJoystick(),

                const Spacer(),

                // Bottom-Right: Weapon Controls & Ammo HUD
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Weapon Switcher Tabs & Ammo
                    _buildWeaponPanel(player, currentWeapon),
                    const SizedBox(height: 12),

                    // Action Controls (Shoot & Reload Buttons)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Reload Button
                        GestureDetector(
                          onTapDown: (_) => player.reload(),
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E222A).withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.amberAccent, width: 2),
                            ),
                            child: const Icon(Icons.replay_rounded,
                                color: Colors.amberAccent, size: 28),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Shoot Button
                        GestureDetector(
                          onTapDown: (_) => _game.mobileShootPressed = true,
                          onTapUp: (_) => _game.mobileShootPressed = false,
                          onTapCancel: () => _game.mobileShootPressed = false,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935).withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFFE53935),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: const Icon(Icons.adjust_rounded,
                                color: Colors.white, size: 40),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBar(Player player) {
    final hpPercent = (player.health / player.maxHealth).clamp(0.0, 1.0);

    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222A).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333842)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '❤️ HEALTH',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              Text(
                '${player.health.toInt()} / ${player.maxHealth.toInt()}',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: hpPercent,
              minHeight: 8,
              backgroundColor: Colors.black45,
              valueColor: AlwaysStoppedAnimation<Color>(
                hpPercent > 0.5
                    ? Colors.greenAccent
                    : (hpPercent > 0.25 ? Colors.amberAccent : Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBadge(WaveManager waveMgr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE53935),
            blurRadius: 8,
          )
        ],
      ),
      child: Text(
        'WAVE ${waveMgr.currentWave}',
        style: GoogleFonts.blackOpsOne(
          fontSize: 16,
          color: Colors.white,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildScoreCoins(Player player) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'SCORE',
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${player.score}',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.amberAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildWeaponPanel(Player player, Weapon currentWeapon) {
    final reserveText = currentWeapon.reserveAmmo > 900
        ? '∞'
        : '${currentWeapon.reserveAmmo}';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222A).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF333842)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Weapon Switcher Tabs
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _weaponTab('PISTOL', 0, player),
              const SizedBox(width: 6),
              _weaponTab('SHOTGUN', 1, player),
              const SizedBox(width: 6),
              _weaponTab('RIFLE', 2, player),
            ],
          ),
          const SizedBox(height: 8),

          // Ammo Counter & Level Status
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LVL ${player.level}',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                currentWeapon.isReloading
                    ? 'RELOADING...'
                    : 'AMMO: ${currentWeapon.currentMagAmmo} / $reserveText',
                style: GoogleFonts.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: currentWeapon.currentMagAmmo == 0
                      ? Colors.redAccent
                      : Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weaponTab(String name, int index, Player player) {

    final isSelected = player.currentWeaponIndex == index;
    return GestureDetector(
      onTap: () => player.switchWeapon(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE53935) : const Color(0xFF0F1115),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          name,
          style: GoogleFonts.orbitron(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildVirtualJoystick() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 2),
      ),
      child: GestureDetector(
        onPanStart: (details) {
          _joystickCenter = details.localPosition;
        },
        onPanUpdate: (details) {
          if (_joystickCenter != null) {
            final delta = details.localPosition - _joystickCenter!;
            final dist = min(delta.distance, 45.0);
            final angle = atan2(delta.dy, delta.dx);

            setState(() {
              _joystickThumb = Offset(cos(angle) * dist, sin(angle) * dist);
            });

            _game.joystickDelta = Vector2(cos(angle), sin(angle)) * (dist / 45.0);
          }
        },
        onPanEnd: (_) {
          setState(() {
            _joystickThumb = Offset.zero;
          });
          _game.joystickDelta = Vector2.zero();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: _joystickThumb,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 6,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
