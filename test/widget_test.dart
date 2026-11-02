import 'package:flutter_test/flutter_test.dart';
import 'package:esports_dynasty/main.dart';

void main() {
  testWidgets('App smoke test: loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EsportsDynastyApp());
    expect(find.byType(EsportsDynastyApp), findsOneWidget);
    // Advance timers so pending splash timer completes cleanly
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
