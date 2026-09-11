import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:sqlite3/open.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  if (Platform.isLinux) {
    open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
  }
  await testMain();
}
