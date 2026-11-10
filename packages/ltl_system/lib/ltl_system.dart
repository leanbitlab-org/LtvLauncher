// LTvLauncher - ltl_system plugin
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

import 'package:flutter/services.dart';

/// Snapshot of the Android debugging (ADB) state.
class AdbStatus {
  final bool adbEnabled;

  /// Wireless debugging (Android 11+); `null` when unsupported or unreadable.
  final bool? wifiAdbEnabled;

  /// Legacy network ADB port (`service.adb.tcp.port`), when active.
  final int? tcpPort;

  final bool developerOptionsEnabled;

  /// WRITE_SECURE_SETTINGS is granted, so the launcher may change the toggles.
  final bool canWriteSecureSettings;

  final String packageName;
  final String? ipAddress;
  final int sdkInt;

  const AdbStatus({
    required this.adbEnabled,
    required this.wifiAdbEnabled,
    required this.tcpPort,
    required this.developerOptionsEnabled,
    required this.canWriteSecureSettings,
    required this.packageName,
    required this.ipAddress,
    required this.sdkInt,
  });

  static const AdbStatus unknown = AdbStatus(
    adbEnabled: false,
    wifiAdbEnabled: null,
    tcpPort: null,
    developerOptionsEnabled: false,
    canWriteSecureSettings: false,
    packageName: '',
    ipAddress: null,
    sdkInt: 0,
  );

  factory AdbStatus.fromMap(Map<Object?, Object?> map) => AdbStatus(
        adbEnabled: map['adbEnabled'] == true,
        wifiAdbEnabled: map['wifiAdbEnabled'] as bool?,
        tcpPort: (map['tcpPort'] as num?)?.toInt(),
        developerOptionsEnabled: map['developerOptionsEnabled'] == true,
        canWriteSecureSettings: map['canWriteSecureSettings'] == true,
        packageName: (map['packageName'] as String?) ?? '',
        ipAddress: map['ipAddress'] as String?,
        sdkInt: (map['sdkInt'] as num?)?.toInt() ?? 0,
      );

  /// The wireless debugging switch exists since Android 11.
  bool get supportsWifiAdb => sdkInt >= 30;

  /// Command that grants the permission needed to toggle ADB from the launcher.
  String get grantCommand {
    final pkg = packageName.isEmpty ? '<package>' : packageName;
    return 'adb shell pm grant $pkg android.permission.WRITE_SECURE_SETTINGS';
  }
}

/// Basic information about the device the launcher runs on.
class LtlDeviceInfo {
  final String manufacturer;
  final String brand;
  final String model;
  final String androidVersion;
  final int sdkInt;
  final String buildId;
  final bool isYaOs;
  final String? ipAddress;

  const LtlDeviceInfo({
    required this.manufacturer,
    required this.brand,
    required this.model,
    required this.androidVersion,
    required this.sdkInt,
    required this.buildId,
    required this.isYaOs,
    required this.ipAddress,
  });

  factory LtlDeviceInfo.fromMap(Map<Object?, Object?> map) => LtlDeviceInfo(
        manufacturer: (map['manufacturer'] as String?) ?? '',
        brand: (map['brand'] as String?) ?? '',
        model: (map['model'] as String?) ?? '',
        androidVersion: (map['androidVersion'] as String?) ?? '',
        sdkInt: (map['sdkInt'] as num?)?.toInt() ?? 0,
        buildId: (map['buildId'] as String?) ?? '',
        isYaOs: map['isYaOs'] == true,
        ipAddress: map['ipAddress'] as String?,
      );

  /// "Brand Model" without repeating the brand when the model already has it.
  String get displayName {
    final vendor = (brand.isNotEmpty ? brand : manufacturer).trim();
    final name = model.trim();
    if (vendor.isEmpty || name.toLowerCase().startsWith(vendor.toLowerCase())) {
      return name;
    }
    return '$vendor $name';
  }
}

/// Dart facade of the native side. Failures resolve to neutral defaults
/// instead of throwing, so the UI never crashes on unsupported devices.
class LtlSystem {
  LtlSystem._();

  static const MethodChannel _channel = MethodChannel('ru.ltl.system/methods');

  static Future<T?> _invoke<T>(String method, [Map<String, Object?>? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  static Future<AdbStatus> getAdbStatus() async {
    final map = await _invoke<Map<Object?, Object?>>('getAdbStatus');
    return map == null ? AdbStatus.unknown : AdbStatus.fromMap(map);
  }

  static Future<bool> setAdbEnabled(bool enabled) async =>
      await _invoke<bool>('setAdbEnabled', {'enabled': enabled}) ?? false;

  static Future<bool> setWifiAdbEnabled(bool enabled) async =>
      await _invoke<bool>('setWifiAdbEnabled', {'enabled': enabled}) ?? false;

  static Future<double> getAnimationScale() async => await _invoke<double>('getAnimationScale') ?? 1.0;

  static Future<bool> setAnimationScale(double scale) async =>
      await _invoke<bool>('setAnimationScale', {'scale': scale}) ?? false;

  static Future<bool> openDeveloperSettings() async => await _invoke<bool>('openDeveloperSettings') ?? false;

  static Future<LtlDeviceInfo?> getDeviceInfo() async {
    final map = await _invoke<Map<Object?, Object?>>('getDeviceInfo');
    return map == null ? null : LtlDeviceInfo.fromMap(map);
  }

  /// Opens [url] in the browser (or the app registered for it).
  static Future<bool> openUrl(String url) async => await _invoke<bool>('openUrl', {'url': url}) ?? false;
}
