import 'package:flutter_test/flutter_test.dart';
import 'package:towd_game/main.dart';


void main() {
  testWidgets('Main menu smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ZombieSurvivalApp());
    expect(find.text('LAST STAND'), findsOneWidget);
  });
}
