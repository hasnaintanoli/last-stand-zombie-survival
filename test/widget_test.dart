import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:last_stand_zombie_survival/main.dart';
import 'package:last_stand_zombie_survival/services/local_storage.dart';
import 'package:last_stand_zombie_survival/services/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'highest_score': 1500,
      'highest_wave': 5,
      'total_kills': 42,
      'total_coins': 120,
      'sound_enabled': true,
      'music_enabled': true,
    });
    await LocalStorage.init();
  });

  testWidgets('Main menu smoke test & UI rendering', (WidgetTester tester) async {
    await tester.pumpWidget(const ZombieSurvivalApp());
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('PLAY GAME'), findsOneWidget);
    expect(find.text('HOW TO PLAY'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
  });

  testWidgets('Quick music toggle on main menu updates preferences', (WidgetTester tester) async {
    await tester.pumpWidget(const ZombieSurvivalApp());
    await tester.pump();

    expect(LocalStorage.getMusicEnabled(), isTrue);

    // Find music note icon button
    final musicButton = find.byIcon(Icons.music_note_rounded);
    expect(musicButton, findsOneWidget);

    await tester.tap(musicButton);
    await tester.pump();

    // Should now be disabled
    expect(LocalStorage.getMusicEnabled(), isFalse);
    expect(find.byIcon(Icons.music_off_rounded), findsOneWidget);
  });

  testWidgets('Quick sound FX toggle on main menu updates preferences', (WidgetTester tester) async {
    await tester.pumpWidget(const ZombieSurvivalApp());
    await tester.pump();

    expect(LocalStorage.getSoundEnabled(), isTrue);

    // Find sound icon button
    final soundButton = find.byIcon(Icons.volume_up_rounded);
    expect(soundButton, findsOneWidget);

    await tester.tap(soundButton);
    await tester.pump();

    // Should now be disabled
    expect(LocalStorage.getSoundEnabled(), isFalse);
    expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
  });

  test('AudioService singleton instance test', () {
    final audio1 = AudioService();
    final audio2 = AudioService.instance;
    expect(identical(audio1, audio2), isTrue);
  });

  test('LocalStorage high score and stats test', () async {
    expect(LocalStorage.getHighScore(), 1500);
    expect(LocalStorage.getHighestWave(), 5);
    expect(LocalStorage.getTotalKills(), 42);
    expect(LocalStorage.getCoins(), 120);

    await LocalStorage.saveHighScore(2000);
    expect(LocalStorage.getHighScore(), 2000);

    // Lower score should not overwrite
    await LocalStorage.saveHighScore(1000);
    expect(LocalStorage.getHighScore(), 2000);
  });
}
