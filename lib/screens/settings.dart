import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/local_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool soundEnabled = LocalStorage.getSoundEnabled();
  bool musicEnabled = LocalStorage.getMusicEnabled();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E222A),
        title: Text(
          'SETTINGS',
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E222A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF333842)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Sound Effects',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Play weapon shooting & hit SFX',
                      style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 12),
                    ),
                    secondary: const Icon(Icons.volume_up, color: Colors.amber),
                    value: soundEnabled,
                    activeThumbColor: const Color(0xFFE53935),
                    onChanged: (val) {
                      setState(() {
                        soundEnabled = val;
                        LocalStorage.setSoundEnabled(val);
                      });
                    },
                  ),
                  const Divider(color: Color(0xFF333842), height: 1),
                  SwitchListTile(
                    title: Text(
                      'Background Music',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Play atmospheric survival BGM',
                      style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 12),
                    ),
                    secondary: const Icon(Icons.music_note, color: Colors.purpleAccent),
                    value: musicEnabled,
                    activeThumbColor: const Color(0xFFE53935),
                    onChanged: (val) {
                      setState(() {
                        musicEnabled = val;
                        LocalStorage.setMusicEnabled(val);
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Reset High Score Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1E222A),
                      title: Text(
                        'Reset Save Stats?',
                        style: GoogleFonts.orbitron(color: Colors.white),
                      ),
                      content: Text(
                        'Are you sure you want to reset your high score and progress?',
                        style: GoogleFonts.inter(color: Colors.grey.shade300),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('RESET', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await LocalStorage.saveHighScore(0);
                    await LocalStorage.saveHighestWave(1);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar( // ignore: use_build_context_synchronously
                      const SnackBar(content: Text('Stats reset successfully!')),
                    );
                  }


                },
                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                label: Text(
                  'RESET STATS & HIGH SCORE',
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
