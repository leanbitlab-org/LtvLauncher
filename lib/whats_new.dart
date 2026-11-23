import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _lastSeenBuildKey = "last_seen_build";
const String _changelogDir = "fastlane/metadata/android/en-US/changelogs";

class WhatsNewData {
  final String version;
  final List<String> notes;

  /// Records this build as seen. Call it once the dialog is dismissed, so an
  /// update whose notice never got shown (app killed first) shows it next launch.
  final Future<void> Function() markSeen;

  const WhatsNewData(this.version, this.notes, this.markSeen);
}

/// Returns the release notes to show once after an update, or null.
///
/// Notes come from the fastlane changelog of the running build number, so the
/// release flow stays the single source. A fresh install (no preferences yet) and
/// a build without a changelog file show nothing and record the build right
/// away. Otherwise the caller records the build with [WhatsNewData.markSeen] when it shows the notes.
Future<WhatsNewData?> pendingWhatsNew(SharedPreferences prefs) async {
  final info = await PackageInfo.fromPlatform();
  final build = int.tryParse(info.buildNumber);
  if (build == null) return null;

  final freshInstall = prefs.getKeys().isEmpty;
  final lastSeen = prefs.getInt(_lastSeenBuildKey);
  Future<void> markSeen() => prefs.setInt(_lastSeenBuildKey, build);
  if (freshInstall || (lastSeen != null && lastSeen >= build)) {
    await markSeen();
    return null;
  }

  final assetPath = "$_changelogDir/$build.txt";
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  if (!manifest.listAssets().contains(assetPath)) {
    await markSeen();
    return null;
  }

  final notes = (await rootBundle.loadString(assetPath))
      .split('\n')
      .map((line) => line.replaceFirst(RegExp(r'^\s*[-*•]\s*'), '').trim())
      .where((line) => line.isNotEmpty)
      .toList();
  if (notes.isEmpty) {
    await markSeen();
    return null;
  }
  return WhatsNewData(info.version, notes, markSeen);
}
