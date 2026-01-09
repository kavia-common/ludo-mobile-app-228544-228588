import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:LudoMobileClientFlutter/core/feature_flags/feature_flags.dart';
import 'package:LudoMobileClientFlutter/main.dart';
import 'package:LudoMobileClientFlutter/presentation/theming/theme_state.dart';

void main() {
  testWidgets('App boots and shows Splash', (WidgetTester tester) async {
    const flags = FeatureFlags(
      enableOnlinePlay: true,
      enableAiMode: true,
      enableStore: true,
      enableProfile: true,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<FeatureFlags>.value(value: flags),
          ChangeNotifierProvider<ThemeState>(create: (_) => ThemeState()),
        ],
        child: const LudoApp(),
      ),
    );

    // Splash renders immediately.
    expect(find.text('Ludo'), findsOneWidget);
    expect(find.text('Loading…'), findsOneWidget);
  });
}
