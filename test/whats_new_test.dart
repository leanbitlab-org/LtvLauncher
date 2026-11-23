import 'package:flauncher/whats_new.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void setPackage(String build) => PackageInfo.setMockInitialValues(
    appName: "x", packageName: "x", version: "1.0", buildNumber: build, buildSignature: "");

Future<SharedPreferences> prefs(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fresh install shows nothing but records the build', () async {
    setPackage("8116");
    final p = await prefs({});
    expect(await pendingWhatsNew(p), isNull);
    expect(p.getInt("last_seen_build"), 8116);
  });

  test('update with a changelog returns bullets without markers until markSeen', () async {
    setPackage("8116");
    final p = await prefs({"accent_color": "x", "last_seen_build": 8115});
    final data = await pendingWhatsNew(p);
    expect(data, isNotNull);
    expect(data!.version, "1.0");
    expect(data.notes.first, startsWith("Fixed apps disappearing"));
    // Not recorded until markSeen is called (the app calls it when the dialog opens).
    expect(p.getInt("last_seen_build"), 8115);
    expect(await pendingWhatsNew(p), isNotNull);
    await data.markSeen();
    expect(p.getInt("last_seen_build"), 8116);
    expect(await pendingWhatsNew(p), isNull);
  });

  test('existing user without a recorded build gets the notes', () async {
    setPackage("8116");
    final p = await prefs({"accent_color": "x"});
    expect(await pendingWhatsNew(p), isNotNull);
  });

  test('build without a changelog file shows nothing', () async {
    setPackage("1");
    final p = await prefs({"accent_color": "x", "last_seen_build": 0});
    expect(await pendingWhatsNew(p), isNull);
    expect(p.getInt("last_seen_build"), 1);
  });
}
