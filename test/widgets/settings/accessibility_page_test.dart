import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/launcher_state.dart';
import 'package:flauncher/widgets/settings/accessibility_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:flauncher/providers/settings_service.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = Size(1280, 720);
    binding.window.devicePixelRatioTestValue = 1.0;
    binding.platformDispatcher.textScaleFactorTestValue = 0.8;
  });

  testWidgets("AccessibilityPage renders correctly when default launcher", (tester) async {
    final appsService = MockAppsService();
    final launcherState = LauncherState();
    final settingsService = MockSettingsService();

    when(appsService.isDefaultLauncher()).thenAnswer((_) async => true);
    when(settingsService.appHighlightAnimationEnabled).thenReturn(true);
    when(settingsService.startOnBoot).thenReturn(false);
    when(settingsService.accentColorHex).thenReturn("7C4DFF");

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppsService>.value(value: appsService),
          ChangeNotifierProvider<LauncherState>.value(value: launcherState),
          ChangeNotifierProvider<SettingsService>.value(value: settingsService),
        ],
        builder: (_, __) => MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: AccessibilityPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Accessibility"), findsOneWidget);
    expect(find.text("LTvLauncher is the default launcher"), findsOneWidget);
    expect(find.text("Set as default launcher"), findsOneWidget);
  });

  testWidgets("AccessibilityPage renders correctly when not default launcher", (tester) async {
    final appsService = MockAppsService();
    final launcherState = LauncherState();
    final settingsService = MockSettingsService();

    when(appsService.isDefaultLauncher()).thenAnswer((_) async => false);
    when(settingsService.appHighlightAnimationEnabled).thenReturn(true);
    when(settingsService.startOnBoot).thenReturn(false);
    when(settingsService.accentColorHex).thenReturn("7C4DFF");

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppsService>.value(value: appsService),
          ChangeNotifierProvider<LauncherState>.value(value: launcherState),
          ChangeNotifierProvider<SettingsService>.value(value: settingsService),
        ],
        builder: (_, __) => MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: AccessibilityPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Accessibility"), findsOneWidget);
    expect(find.text("LTvLauncher is not the default launcher"), findsOneWidget);
  });
}
