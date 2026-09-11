import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flauncher/database.dart';
import 'package:flauncher/models/app.dart';
import 'package:flauncher/models/category.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flutter_test/flutter_test.dart' hide Category;
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../mocks.dart';
import '../mocks.mocks.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group("removeCustomAppBanner", () {

    test("removes custom banner and deletes file if it exists", () async {
      final channel = MockFLauncherChannel();
      final database = MockFLauncherDatabase();
      final appsService = await _buildInitialisedAppsService(channel, database);

      // Create a temp file
      final tempFile = await File('${Directory.systemTemp.path}/test_banner.png').create();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_banner_test.app', tempFile.path);

      var notified = false;
      appsService.addListener(() {
        notified = true;
      });

      await appsService.removeCustomAppBanner('test.app');

      expect(await tempFile.exists(), isFalse);
      expect(prefs.containsKey('custom_banner_test.app'), isFalse);
      expect(notified, isTrue);
    });

    test("handles file deletion errors gracefully", () async {
      final channel = MockFLauncherChannel();
      final database = MockFLauncherDatabase();
      final appsService = await _buildInitialisedAppsService(channel, database);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_banner_test.app', '/invalid/path/that/does/not/exist.png');

      var notified = false;
      appsService.addListener(() {
        notified = true;
      });

      // Should not throw an exception
      await appsService.removeCustomAppBanner('test.app');

      expect(prefs.containsKey('custom_banner_test.app'), isFalse);
      expect(notified, isTrue);
    });

    test("works when custom banner path is null", () async {
      final channel = MockFLauncherChannel();
      final database = MockFLauncherDatabase();
      final appsService = await _buildInitialisedAppsService(channel, database);

      final prefs = await SharedPreferences.getInstance();

      var notified = false;
      appsService.addListener(() {
        notified = true;
      });

      // Should not throw an exception
      await appsService.removeCustomAppBanner('test.app');

      expect(prefs.containsKey('custom_banner_test.app'), isFalse);
      expect(notified, isTrue);
    });
  });

  group("AppsService Category Integration", () {
    test("loads categories with apps correctly", () async {
      final channel = MockFLauncherChannel();
      final database = MockFLauncherDatabase();

      final testApp1 = App(packageName: "app.1", name: "App 1", version: "1.0.0", hidden: false);
      final testApp2 = App(packageName: "app.2", name: "App 2", version: "1.0.0", hidden: false);
      final testApp3 = App(packageName: "app.3", name: "App 3", version: "1.0.0", hidden: false);
      final hiddenApp = App(packageName: "app.hidden", name: "Hidden App", version: "1.0.0", hidden: true);

      final category = Category(id: 1, name: "Test Category", order: 0);

      when(channel.getApplications()).thenAnswer((_) => Future.value([
        {'packageName': 'app.1', 'name': 'App 1', 'version': '1.0.0', 'sideloaded': false},
        {'packageName': 'app.2', 'name': 'App 2', 'version': '1.0.0', 'sideloaded': false},
        {'packageName': 'app.3', 'name': 'App 3', 'version': '1.0.0', 'sideloaded': false},
        {'packageName': 'app.hidden', 'name': 'Hidden App', 'version': '1.0.0', 'sideloaded': false},
      ]));
      when(channel.getApplicationIcon(any)).thenAnswer((_) => Future.value(Uint8List(0)));
      when(channel.getApplicationBanner(any)).thenAnswer((_) => Future.value(Uint8List(0)));

      when(database.getApplications()).thenAnswer((_) => Future.value([testApp1, testApp2, testApp3, hiddenApp]));
      when(database.getCategories()).thenAnswer((_) => Future.value([category]));
      when(database.getAppsCategories()).thenAnswer((_) => Future.value([
        AppCategory(categoryId: 1, appPackageName: "app.1", order: 1),
        AppCategory(categoryId: 1, appPackageName: "app.2", order: 0),
        AppCategory(categoryId: 1, appPackageName: "app.3", order: 2),
      ]));
      when(database.getLauncherSpacers()).thenAnswer((_) => Future.value([]));
      when(database.transaction(any)).thenAnswer((realInvocation) => realInvocation.positionalArguments[0]());
      when(database.wasCreated).thenReturn(false);
      when(database.persistApps(any)).thenAnswer((_) => Future.value());
      when(database.deleteApps(any)).thenAnswer((_) => Future.value());

      final appsService = AppsService(channel, database);

      // Wait for initialization
      while (!appsService.initialized) {
        await Future.delayed(const Duration(milliseconds: 10));
      }

      final categories = appsService.categories;
      expect(categories.length, 1);
      expect(categories[0].name, "Test Category");

      final appsInCategory = categories[0].applications;
      // Hidden apps should be filtered out from categories
      expect(appsInCategory.length, 3);

      // Should be ordered by the 'order' in AppCategory (0: app.2, 1: app.1, 2: app.3)
      expect(appsInCategory[0].packageName, "app.2");
      expect(appsInCategory[1].packageName, "app.1");
      expect(appsInCategory[2].packageName, "app.3");
    });

    test("saveApplicationOrderInCategory updates local categoryOrders map", () async {
      final channel = MockFLauncherChannel();
      final database = MockFLauncherDatabase();

      final testApp1 = App(packageName: "app.1", name: "App 1", version: "1.0.0", hidden: false);
      final testApp2 = App(packageName: "app.2", name: "App 2", version: "1.0.0", hidden: false);
      final category = Category(id: 1, name: "Test Category", order: 0);

      when(channel.getApplications()).thenAnswer((_) => Future.value([
        {'packageName': 'app.1', 'name': 'App 1', 'version': '1.0.0', 'sideloaded': false},
        {'packageName': 'app.2', 'name': 'App 2', 'version': '1.0.0', 'sideloaded': false},
      ]));
      when(channel.getApplicationIcon(any)).thenAnswer((_) => Future.value(Uint8List(0)));
      when(channel.getApplicationBanner(any)).thenAnswer((_) => Future.value(Uint8List(0)));

      when(database.getApplications()).thenAnswer((_) => Future.value([testApp1, testApp2]));
      when(database.getCategories()).thenAnswer((_) => Future.value([category]));
      when(database.getAppsCategories()).thenAnswer((_) => Future.value([
        AppCategory(categoryId: 1, appPackageName: "app.1", order: 0),
        AppCategory(categoryId: 1, appPackageName: "app.2", order: 1),
      ]));
      when(database.getLauncherSpacers()).thenAnswer((_) => Future.value([]));
      when(database.transaction(any)).thenAnswer((realInvocation) => realInvocation.positionalArguments[0]());
      when(database.wasCreated).thenReturn(false);
      when(database.replaceAppsCategories(any)).thenAnswer((_) => Future.value());

      final appsService = AppsService(channel, database);

      while (!appsService.initialized) {
        await Future.delayed(const Duration(milliseconds: 10));
      }

      final categoryObj = appsService.categories.first;
      
      // Let's reorder them locally: move app 1 to the end
      appsService.reorderApplication(categoryObj, 0, 1);
      
      // Now save
      await appsService.saveApplicationOrderInCategory(categoryObj);

      // Verify that local categoryOrders reflect the new indices (app.2 order is 0, app.1 order is 1)
      expect(testApp2.categoryOrders[1], 0);
      expect(testApp1.categoryOrders[1], 1);
    });

    test("sortCategory sorts alphabetically case-insensitively", () async {
      final channel = MockFLauncherChannel();
      final database = MockFLauncherDatabase();

      final appB = App(packageName: "b", name: "bravo", version: "1.0", hidden: false);
      final appA = App(packageName: "a", name: "Alpha", version: "1.0", hidden: false);
      final appC = App(packageName: "c", name: "charlie", version: "1.0", hidden: false);

      final category = Category(id: 1, name: "Test Category", order: 0, sort: CategorySort.alphabetical);
      category.applications.addAll([appB, appC, appA]);

      final appsService = await _buildInitialisedAppsService(channel, database);
      appsService.sortCategory(category);

      expect(category.applications.map((a) => a.packageName).toList(), ["a", "b", "c"]);
    });

    test("default categories places TV Apps section before Non-TV Apps section", () async {
      final channel = MockFLauncherChannel();
      final database = MockFLauncherDatabase();

      when(database.insertCategory(any)).thenAnswer((inv) {
        return Future.value(1);
      });
      when(database.insertAppsCategories(any)).thenAnswer((_) => Future.value());

      final appsService = await _buildInitialisedAppsService(channel, database);
      await appsService.addCategory("TV Apps");
      await appsService.addCategory("Non-TV Apps");

      expect((appsService.launcherSections[0] as Category).name, "TV Apps");
      expect((appsService.launcherSections[1] as Category).name, "Non-TV Apps");
    });

    test("existing install with Non-TV Apps above TV Apps is reordered so TV Apps is on top", () async {
      final channel = MockFLauncherChannel();
      final database = MockFLauncherDatabase();

      final nonTvCat = Category(id: 1, name: "Non-TV Apps", order: 0);
      final tvCat = Category(id: 2, name: "TV Apps", order: 1);

      when(channel.getApplications()).thenAnswer((_) => Future.value([]));
      when(channel.getApplicationIcon(any)).thenAnswer((_) => Future.value(Uint8List(0)));
      when(channel.getApplicationBanner(any)).thenAnswer((_) => Future.value(Uint8List(0)));
      when(database.getApplications()).thenAnswer((_) => Future.value([]));
      when(database.getAppsCategories()).thenAnswer((_) => Future.value([]));
      when(database.getCategories()).thenAnswer((_) => Future.value([nonTvCat, tvCat]));
      when(database.getLauncherSpacers()).thenAnswer((_) => Future.value([]));
      when(database.transaction(any)).thenAnswer((realInvocation) => realInvocation.positionalArguments[0]());
      when(database.persistApps(any)).thenAnswer((_) => Future.value());
      when(database.updateCategories(any)).thenAnswer((_) => Future.value());
      when(database.updateSpacers(any)).thenAnswer((_) => Future.value());
      when(database.updateCategory(any, any)).thenAnswer((_) => Future.value(true));
      when(database.wasCreated).thenReturn(false);

      final appsService = AppsService(channel, database);
      while (!appsService.initialized) {
        await Future.delayed(const Duration(milliseconds: 10));
      }

      expect((appsService.launcherSections[0] as Category).name, "TV Apps");
      expect((appsService.launcherSections[1] as Category).name, "Non-TV Apps");
    });
  });
}

Future<AppsService> _buildInitialisedAppsService(
  MockFLauncherChannel channel,
  MockFLauncherDatabase database,
) async {
  when(channel.getApplications()).thenAnswer((_) => Future.value([]));
  when(channel.getApplicationIcon(any)).thenAnswer((_) => Future.value(Uint8List(0)));
  when(channel.getApplicationBanner(any)).thenAnswer((_) => Future.value(Uint8List(0)));
  when(database.getApplications()).thenAnswer((_) => Future.value([]));
  when(database.getAppsCategories()).thenAnswer((_) => Future.value([]));
  when(database.getCategories()).thenAnswer((_) => Future.value([]));
  when(database.getLauncherSpacers()).thenAnswer((_) => Future.value([]));
  when(database.transaction(any)).thenAnswer((realInvocation) => realInvocation.positionalArguments[0]());
  when(database.wasCreated).thenReturn(false);
  final appsService = AppsService(channel, database);

  while (!appsService.initialized) {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  await untilCalled(channel.addAppsChangedListener(any));
  clearInteractions(channel);
  clearInteractions(database);
  return appsService;
}
