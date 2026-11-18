/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flauncher/database.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/models/app.dart';
import 'package:flauncher/models/category.dart';
import 'package:flauncher/widgets/add_to_category_dialog.dart';
import 'package:flauncher/widgets/application_info_panel.dart';
import 'package:flauncher/widgets/settings/applications_panel_page.dart';
import 'package:flauncher/widgets/settings/app_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../mocks.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = Size(1280, 720);
    binding.window.devicePixelRatioTestValue = 1.0;
    // Scale-down the font size because the font 'Ahem' used when running tests is much wider than Roboto
    binding.platformDispatcher.textScaleFactorTestValue = 0.8;
  });

  testWidgets("TV Applications shows TV apps", (tester) async {
    final appsService = MockAppsService();
    when(appsService.applications).thenReturn([
      fakeApp(
        packageName: "me.efesser.flauncher",
        name: "FLauncher",
        sideloaded: false,
        hidden: false,
      )
    ]);

    await _pumpWidgetWithProviders(tester, appsService);

    expect(find.text("TV Apps"), findsOneWidget);
    expect(find.text("FLauncher"), findsOneWidget);
  });

  testWidgets("Non-TV Applications shows Non-TV apps", (tester) async {
    final appsService = MockAppsService();
    when(appsService.applications).thenReturn([
      fakeApp(
        packageName: "me.efesser.flauncher",
        name: "FLauncher",
        sideloaded: true,
        hidden: false,
      )
    ]);

    await _pumpWidgetWithProviders(tester, appsService);

    await tester.tap(find.byIcon(Icons.android));
    await tester.pumpAndSettle();

    expect(find.text("Non-TV Apps"), findsOneWidget);
    expect(find.text("FLauncher"), findsOneWidget);
  });

  testWidgets("Hidden Applications shows hidden apps", (tester) async {
    final appsService = MockAppsService();
    when(appsService.applications).thenReturn([
      fakeApp(
        packageName: "me.efesser.flauncher",
        name: "FLauncher",
        sideloaded: false,
        hidden: true,
      )
    ]);

    await _pumpWidgetWithProviders(tester, appsService);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pumpAndSettle();

    expect(find.text("Hidden Apps"), findsOneWidget);
    expect(find.text("FLauncher"), findsOneWidget);
  });

  testWidgets("'Add' opens AddToCategoryDialog", (tester) async {
    final appsService = MockAppsService();
    final application = fakeApp(
      packageName: "me.efesser.flauncher",
      name: "FLauncher",
      version: "1.0.0",
    );
    when(appsService.applications).thenReturn([application]);
    when(appsService.launcherSections).thenReturn([fakeCategory()]);

    await _pumpWidgetWithProviders(tester, appsService);

    await tester.tap(find.text("FLauncher"));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Add to..."));
    await tester.pumpAndSettle();
    expect(find.byType(AddToCategoryDialog), findsOneWidget);
  });

  testWidgets("'Info' calls openAppInfo on AppsService", (tester) async {
    final appsService = MockAppsService();
    final application = fakeApp(
      packageName: "me.efesser.flauncher",
      name: "FLauncher",
      version: "1.0.0",
    );
    when(appsService.applications).thenReturn([application]);
    when(appsService.launcherSections).thenReturn([fakeCategory()]);

    await _pumpWidgetWithProviders(tester, appsService);

    await tester.tap(find.text("FLauncher"));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Application info"));
    await tester.pumpAndSettle();
    verify(appsService.openAppInfo(application));
  });
}

Future<void> _pumpWidgetWithProviders(WidgetTester tester, MockAppsService appsService) async {
  when(appsService.categories).thenReturn([]);
  when(appsService.isAppInFavorites(any)).thenReturn(false);
  when(appsService.getAppIcon(any)).thenAnswer((_) async => kTransparentImage);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppsService>.value(value: appsService),
      ],
      builder: (_, __) => MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routes: {
          AppDetailsPage.routeName: (context) {
            final app = ModalRoute.of(context)!.settings.arguments as App;
            return Scaffold(body: AppDetailsPage(application: app));
          },
        },
        home: Scaffold(body: ApplicationsPanelPage()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
