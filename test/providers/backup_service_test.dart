import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flauncher/database.dart';
import 'package:flauncher/models/category.dart';
import 'package:flauncher/providers/backup_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FLauncherDatabase database;
  late SharedPreferences sharedPreferences;
  late BackupService backupService;
  late Directory tempDir;

  setUp(() async {
    SharedPreferencesStorePlatform.instance = InMemorySharedPreferencesStore.empty();
    sharedPreferences = await SharedPreferences.getInstance();
    database = FLauncherDatabase.inMemory();
    backupService = BackupService(database, sharedPreferences);

    tempDir = await Directory.systemTemp.createTemp('ltv_backup_test');

    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return tempDir.path;
      },
    );
  });

  tearDown(() async {
    await database.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      null,
    );
  });

  test("Export and Import Backup preserves database and SharedPreferences settings", () async {
    // 1. Populate database and SharedPreferences
    await sharedPreferences.setBool("app_highlight_animation_enabled", false);
    await sharedPreferences.setString("themes", "modern");
    await sharedPreferences.setInt("test_int_key", 42);

    await database.persistApps([
      AppsCompanion.insert(
        packageName: "com.test.app1",
        name: "Test App 1",
        version: "1.0.0",
        hidden: const Value(false),
      ),
      AppsCompanion.insert(
        packageName: "com.test.app2",
        name: "Test App 2",
        version: "2.0.0",
        hidden: const Value(true),
      ),
    ]);

    final categoryId = await database.insertCategory(CategoriesCompanion.insert(
      name: "Custom Category",
      order: 1,
    ));

    await database.into(database.appsCategories).insert(AppsCategoriesCompanion.insert(
      categoryId: categoryId,
      appPackageName: "com.test.app1",
      order: 0,
    ));

    await database.into(database.launcherSpacers).insert(LauncherSpacersCompanion.insert(
      height: 100,
      order: 2,
    ));

    // 2. Export Backup
    final backupPath = await backupService.exportBackup();
    final backupFile = File(backupPath);
    expect(await backupFile.exists(), isTrue);

    // Verify backup JSON content
    final jsonContent = await backupFile.readAsString();
    final Map<String, dynamic> decoded = json.decode(jsonContent);
    expect(decoded["version"], 1);
    expect(decoded["settings"]["app_highlight_animation_enabled"], false);
    expect(decoded["settings"]["themes"], "modern");
    expect(decoded["settings"]["test_int_key"], 42);
    expect((decoded["apps"] as List).length, 2);
    expect((decoded["categories"] as List).length, 1);
    expect((decoded["appsCategories"] as List).length, 1);
    expect((decoded["spacers"] as List).length, 1);

    // 3. Clear database and SharedPreferences
    await sharedPreferences.clear();
    await database.transaction(() async {
      await database.customStatement('DELETE FROM apps_categories;');
      await database.customStatement('DELETE FROM launcher_spacers;');
      await database.customStatement('DELETE FROM categories;');
      await database.customStatement('DELETE FROM apps;');
    });

    expect(sharedPreferences.getKeys(), isEmpty);
    expect(await database.getApplications(), isEmpty);
    expect(await database.getCategories(), isEmpty);

    // 4. Import Backup
    await backupService.importBackup();

    // 5. Verify SharedPreferences and database restored
    expect(sharedPreferences.getBool("app_highlight_animation_enabled"), false);
    expect(sharedPreferences.getString("themes"), "modern");
    expect(sharedPreferences.getInt("test_int_key"), 42);

    final apps = await database.getApplications();
    expect(apps.length, 2);
    final app1 = apps.firstWhere((a) => a.packageName == "com.test.app1");
    expect(app1.name, "Test App 1");
    expect(app1.hidden, false);
    final app2 = apps.firstWhere((a) => a.packageName == "com.test.app2");
    expect(app2.name, "Test App 2");
    expect(app2.hidden, true);

    final categories = await database.getCategories();
    expect(categories.length, 1);
    expect(categories[0].name, "Custom Category");

    final appsCategories = await database.getAppsCategories();
    expect(appsCategories.length, 1);
    expect(appsCategories[0].appPackageName, "com.test.app1");
    expect(appsCategories[0].categoryId, categoryId);

    final spacers = await database.getLauncherSpacers();
    expect(spacers.length, 1);
    expect(spacers[0].height, 100);
  });

  test("Import Backup handles out-of-bounds CategorySort and CategoryType values gracefully", () async {
    final file = File('${tempDir.path}/ltv_backup_corrupted.json');
    await file.writeAsString(json.encode({
      "version": 1,
      "settings": {},
      "apps": [],
      "categories": [
        {
          "id": 100,
          "name": "Corrupted Enum Category",
          "sort": 999, // out of bounds
          "type": 999, // out of bounds
          "rowHeight": 110,
          "columnsCount": 6,
          "order": 0,
        }
      ],
      "appsCategories": [],
      "spacers": [],
    }));

    await backupService.importBackup(file);
    final categories = await database.getCategories();
    expect(categories.length, 1);
    expect(categories[0].sort, CategorySort.manual);
    expect(categories[0].type, CategoryType.grid);
  });

  test("Backup list includes backups exported before path_provider_android 2.3 moved the downloads folder", () async {
    final originalPathProvider = PathProviderPlatform.instance;
    addTearDown(() => PathProviderPlatform.instance = originalPathProvider);
    final externalDir = Directory('${tempDir.path}/external')..createSync();
    PathProviderPlatform.instance = _AndroidPathProviderPlatform(externalDir.path, tempDir.path);

    // Older releases exported to <external files>/downloads; current ones use <external files>/Download.
    final legacyDir = Directory('${externalDir.path}/downloads')..createSync();
    final currentDir = Directory('${externalDir.path}/Download')..createSync();
    File('${legacyDir.path}/ltv_backup_20260501_120000.json').writeAsStringSync('{}');
    File('${currentDir.path}/ltv_backup_20261024_120000.json').writeAsStringSync('{}');

    final names = (await backupService.getBackupFiles()).map((entry) => entry.name);

    expect(names, containsAll(["ltv_backup_20260501_120000.json", "ltv_backup_20261024_120000.json"]));
  });

  test("Backup list shows a backup once when several folders hold a copy of it", () async {
    final originalPathProvider = PathProviderPlatform.instance;
    addTearDown(() => PathProviderPlatform.instance = originalPathProvider);
    final externalDir = Directory('${tempDir.path}/external')..createSync();
    PathProviderPlatform.instance = _AndroidPathProviderPlatform(externalDir.path, tempDir.path);

    final downloadDir = Directory('${externalDir.path}/Download')..createSync();
    File('${downloadDir.path}/ltv_backup_20261024_120000.json').writeAsStringSync('{"version": 1}');
    File('${tempDir.path}/ltv_backup_20261024_120000.json').writeAsStringSync('{"version": 1}');
    File('${downloadDir.path}/ltv_backup_20261024_130000.json').writeAsStringSync('{"version": 1}');

    final names = (await backupService.getBackupFiles()).map((entry) => entry.name).toList();

    expect(names..sort(), ["ltv_backup_20261024_120000.json", "ltv_backup_20261024_130000.json"]);
  });
}

/// Mirrors path_provider_android 2.3+, which maps getDownloadsDirectory() to `<external files>/Download`.
class _AndroidPathProviderPlatform extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  final String externalStoragePath;
  final String documentsPath;

  _AndroidPathProviderPlatform(this.externalStoragePath, this.documentsPath);

  @override
  Future<String?> getExternalStoragePath() async => externalStoragePath;

  @override
  Future<String?> getDownloadsPath() async => '$externalStoragePath/Download';

  @override
  Future<String?> getApplicationDocumentsPath() async => documentsPath;
}
