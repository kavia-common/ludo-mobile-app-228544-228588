import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:LudoMobileClientFlutter/core/feature_flags/feature_flags.dart';
import 'package:LudoMobileClientFlutter/data/social/social_repository.dart';
import 'package:LudoMobileClientFlutter/main.dart';
import 'package:LudoMobileClientFlutter/presentation/state/invite_controller.dart';
import 'package:LudoMobileClientFlutter/presentation/state/settings_controller.dart';
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
          Provider<SocialRepository>(create: (_) => SocialRepository()),
          ChangeNotifierProvider<SettingsController>(create: (_) => SettingsController()),
          ChangeNotifierProvider<InviteController>(create: (_) => InviteController()),
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
