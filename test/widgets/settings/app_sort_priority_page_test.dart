import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/settings/app_sort_priority_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class TestAppsService extends Mock implements AppsService {
  String? lastPriority;
  int callCount = 0;

  @override
  void setAppSortPriority(String priority) {
    lastPriority = priority;
    callCount++;
  }
}

void main() {
  late SettingsService settingsService;
  late SharedPreferences sharedPreferences;
  late TestAppsService testAppsService;

  setUp(() async {
    SharedPreferencesStorePlatform.instance = InMemorySharedPreferencesStore.empty();
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    settingsService = SettingsService(sharedPreferences);
    testAppsService = TestAppsService();
  });

  Widget buildSubject() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: settingsService),
          ChangeNotifierProvider<AppsService>.value(value: testAppsService),
        ],
        child: const Scaffold(
          body: AppSortPriorityPage(),
        ),
      ),
    );
  }

  testWidgets('renders all sort priority options', (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('App Sort Priority'), findsOneWidget);
    expect(find.text('TV Apps First'), findsOneWidget);
    expect(find.text('Non-TV Apps First'), findsOneWidget);
    expect(find.text('None (All Mixed)'), findsOneWidget);
  });

  testWidgets('selecting Non-TV apps first updates setting and notifies appsService', (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Non-TV Apps First'));
    await tester.pumpAndSettle();

    expect(settingsService.appSortPriority, APP_SORT_NON_TV_FIRST);
    expect(testAppsService.lastPriority, APP_SORT_NON_TV_FIRST);
    expect(testAppsService.callCount, 1);
  });

  testWidgets('selecting No priority updates setting and notifies appsService', (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('None (All Mixed)'));
    await tester.pumpAndSettle();

    expect(settingsService.appSortPriority, APP_SORT_NONE);
    expect(testAppsService.lastPriority, APP_SORT_NONE);
    expect(testAppsService.callCount, 1);
  });

  testWidgets('selecting TV apps first updates setting and notifies appsService', (WidgetTester tester) async {
    // Start with non-tv first
    await settingsService.setAppSortPriority(APP_SORT_NON_TV_FIRST);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('TV Apps First'));
    await tester.pumpAndSettle();

    expect(settingsService.appSortPriority, APP_SORT_TV_FIRST);
    expect(testAppsService.lastPriority, APP_SORT_TV_FIRST);
    expect(testAppsService.callCount, 1);
  });
}
