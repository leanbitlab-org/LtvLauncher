import 'package:flauncher/flauncher_app.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/settings/app_language_page.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  late SettingsService settingsService;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    SharedPreferencesStorePlatform.instance = InMemorySharedPreferencesStore.empty();
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    settingsService = SettingsService(sharedPreferences);
  });

  Widget buildSubject() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider<SettingsService>.value(
        value: settingsService,
        child: const Scaffold(
          body: AppLanguagePage(),
        ),
      ),
    );
  }

  testWidgets('renders all language options', (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('System Default'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Spanish'), findsOneWidget);
    expect(find.text('French'), findsOneWidget);
    expect(find.text('German'), findsOneWidget);
  });

  testWidgets('tapping Spanish option updates appLanguage preference to es', (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Spanish'));
    await tester.pumpAndSettle();

    expect(settingsService.appLanguage, 'es');
    expect(settingsService.appLocale, equals(const Locale('es')));
  });

  testWidgets('tapping French option updates appLanguage preference to fr', (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('French'));
    await tester.pumpAndSettle();

    expect(settingsService.appLanguage, 'fr');
    expect(settingsService.appLocale, equals(const Locale('fr')));
  });

  testWidgets('tapping Japanese option updates appLanguage preference to ja', (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Japanese'), 100);
    await tester.tap(find.text('Japanese'));
    await tester.pumpAndSettle();

    expect(settingsService.appLanguage, 'ja');
    expect(settingsService.appLocale, equals(const Locale('ja')));
  });

  testWidgets('tapping Slovenian option updates appLanguage preference to sl', (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Slovenian'), 300);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Slovenian'));
    await tester.pumpAndSettle();

    expect(settingsService.appLanguage, 'sl');
    expect(settingsService.appLocale, equals(const Locale('sl')));
  });

  testWidgets('tapping Hebrew option updates appLanguage preference to he', (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Hebrew'), 300);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hebrew'));
    await tester.pumpAndSettle();

    expect(settingsService.appLanguage, 'he');
    expect(settingsService.appLocale, equals(const Locale('he')));
  });

  testWidgets('autofocuses selected language tile', (WidgetTester tester) async {
    await settingsService.setAppLanguage('es');
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final spanishTile = tester.widget<FocusableSettingsTile>(
      find.ancestor(of: find.text('Spanish'), matching: find.byType(FocusableSettingsTile)),
    );
    expect(spanishTile.autofocus, isTrue);
  });

  group('resolveAppLocale fallback resolution', () {
    test('defaults to English when system locale has no translation available', () {
      final resolved = resolveAppLocale([const Locale('sv')], AppLocalizations.supportedLocales);
      expect(resolved, equals(const Locale('en')));
    });

    test('defaults to English when preferredLocales list is null or empty', () {
      expect(resolveAppLocale(null, AppLocalizations.supportedLocales), equals(const Locale('en')));
      expect(resolveAppLocale([], AppLocalizations.supportedLocales), equals(const Locale('en')));
    });

    test('picks supported locale when matching translation is available', () {
      final resolved = resolveAppLocale([const Locale('es', 'ES')], AppLocalizations.supportedLocales);
      expect(resolved, equals(const Locale('es')));

      final slResolved = resolveAppLocale([const Locale('sl')], AppLocalizations.supportedLocales);
      expect(slResolved, equals(const Locale('sl')));

      final heResolved = resolveAppLocale([const Locale('he')], AppLocalizations.supportedLocales);
      expect(heResolved, equals(const Locale('he')));

      final iwResolved = resolveAppLocale([const Locale('iw')], AppLocalizations.supportedLocales);
      expect(iwResolved, equals(const Locale('he')));
    });

    test('respects user fallback order in preferredLocales', () {
      // First is unsupported Swedish, second is supported French
      final resolved = resolveAppLocale([const Locale('sv'), const Locale('fr')], AppLocalizations.supportedLocales);
      expect(resolved, equals(const Locale('fr')));
    });
  });
}
