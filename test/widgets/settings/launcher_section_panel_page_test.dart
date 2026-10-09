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

import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/models/category.dart';
import 'package:flauncher/widgets/settings/launcher_section_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

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

  testWidgets("Category is displayed", (tester) async {
    final appsService = MockAppsService();
    final favoritesCategory =
        fakeCategory(name: "Favorites", sort: CategorySort.alphabetical, type: CategoryType.grid, columnsCount: 6);
    when(appsService.launcherSections).thenReturn([
      favoritesCategory,
      fakeCategory(name: "Applications"),
    ]);

    await _pumpWidgetWithProviders(tester, appsService, 0);

    expect(find.text("Favorites"), findsWidgets);
  });

  testWidgets("'Delete' calls AppsService", (tester) async {
    final appsService = MockAppsService();
    final favoritesCategory =
        fakeCategory(name: "Favorites", sort: CategorySort.alphabetical, type: CategoryType.row, rowHeight: 110);
    when(appsService.launcherSections).thenReturn([
      favoritesCategory,
      fakeCategory(name: "Applications"),
    ]);

    await _pumpWidgetWithProviders(tester, appsService, 0);

    final deleteButton = find.text("Delete");
    expect(deleteButton, findsOneWidget);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    verify(appsService.deleteSection(0));
  });

  testWidgets("Saving a new section returns to the previous page", (tester) async {
    final appsService = MockAppsService();
    when(appsService.launcherSections).thenReturn([fakeCategory(name: "Favorites")]);
    when(appsService.addSpacer(any)).thenAnswer((_) async {});

    await tester.pumpWidget(
      ChangeNotifierProvider<AppsService>.value(
        value: appsService,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              child: const Text("Open"),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => Scaffold(body: LauncherSectionPanelPage())),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text("Open"));
    await tester.pumpAndSettle();
    expect(find.text("New section"), findsOneWidget);

    await tester.tap(find.text("Category"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Spacer").last);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Save"));
    await tester.pumpAndSettle();

    verify(appsService.addSpacer(any));
    // A live "New section" form here let the Type dropdown crash the panel.
    expect(find.text("New section"), findsNothing);
    expect(find.text("Open"), findsOneWidget);
  });
}

Future<void> _pumpWidgetWithProviders(WidgetTester tester, AppsService appsService, int sectionIndex) async {
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
        home: Scaffold(body: LauncherSectionPanelPage(sectionIndex: sectionIndex)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
