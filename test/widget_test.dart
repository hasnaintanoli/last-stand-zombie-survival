import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:last_stand_zombie_survival/main.dart';
import 'package:last_stand_zombie_survival/services/local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Main menu smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.init();

    await tester.pumpWidget(const ZombieSurvivalApp());
    await tester.pump();

    expect(find.text('LAST STAND'), findsOneWidget);
    expect(find.text('SURVIVE THE NIGHT'), findsOneWidget);
  });
}
