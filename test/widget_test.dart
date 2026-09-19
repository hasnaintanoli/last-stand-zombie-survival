import 'package:flutter_test/flutter_test.dart';
import 'package:last_stand_zombie_survival/main.dart';


void main() {
  testWidgets('Main menu smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ZombieSurvivalApp());
    expect(find.text('LAST STAND'), findsOneWidget);
  });
}
