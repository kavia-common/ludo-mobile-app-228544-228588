import 'package:flutter_test/flutter_test.dart';

import 'package:LudoMobileClientFlutter/main.dart';

void main() {
  testWidgets('App boots and shows Splash', (WidgetTester tester) async {
    await tester.pumpWidget(const LudoApp());

    // Splash renders immediately.
    expect(find.text('Ludo'), findsOneWidget);
    expect(find.text('Loading…'), findsOneWidget);
  });
}
