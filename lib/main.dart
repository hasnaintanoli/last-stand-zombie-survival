import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/local_storage.dart';
import 'screens/main_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to landscape or portrait / enable immersive mode for games
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  // Initialize Local Storage
  await LocalStorage.init();

  runApp(const ZombieSurvivalApp());
}

class ZombieSurvivalApp extends StatelessWidget {
  const ZombieSurvivalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Last Stand: Zombie Survival',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFFE53935),
        scaffoldBackgroundColor: const Color(0xFF0F1115),
      ),
      home: const MainMenuScreen(),
    );
  }
}
