/*
 * LTvLauncher
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

import 'package:flauncher/ltl/ltl_strings.dart';
import 'package:flutter/material.dart';
import 'package:ltl_system/ltl_system.dart';

import 'focusable_settings_tile.dart';

/// "Development" section: ADB with a live status, wireless debugging,
/// system animation speed and device information.
class DeveloperSettingsPage extends StatefulWidget {
  static const String routeName = "developer_settings_panel";

  const DeveloperSettingsPage({super.key});

  @override
  State<DeveloperSettingsPage> createState() => _DeveloperSettingsPageState();
}

class _DeveloperSettingsPageState extends State<DeveloperSettingsPage> with WidgetsBindingObserver {
  static const List<double> _animationSteps = [1.0, 0.5, 0.0];

  AdbStatus _status = AdbStatus.unknown;
  LtlDeviceInfo? _device;
  double _animationScale = 1.0;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The user may have changed something in the system settings meanwhile.
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    final status = await LtlSystem.getAdbStatus();
    final device = await LtlSystem.getDeviceInfo();
    final scale = await LtlSystem.getAnimationScale();
    if (!mounted) return;
    setState(() {
      _status = status;
      _device = device;
      _animationScale = scale;
      _loading = false;
    });
  }

  Future<void> _runPrivileged(Future<bool> Function() action) async {
    if (_busy) return;
    if (!_status.canWriteSecureSettings) {
      await _showGrantDialog();
      return;
    }
    setState(() => _busy = true);
    final ok = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(LtlStrings.of(context).changeFailed)),
      );
    }
    await _refresh();
  }

  void _toggleAdb() => _runPrivileged(() => LtlSystem.setAdbEnabled(!_status.adbEnabled));

  void _toggleWifiAdb() => _runPrivileged(() => LtlSystem.setWifiAdbEnabled(_status.wifiAdbEnabled != true));

  void _cycleAnimationScale() {
    final index = _animationSteps.indexWhere((step) => (step - _animationScale).abs() < 0.01);
    final next = _animationSteps[(index + 1) % _animationSteps.length];
    _runPrivileged(() => LtlSystem.setAnimationScale(next));
  }

  String _animationLabel(LtlStrings strings) {
    if (_animationScale <= 0.001) return strings.animationOff;
    final whole = _animationScale == _animationScale.roundToDouble();
    return '${_animationScale.toStringAsFixed(whole ? 0 : 1)}x';
  }

  String _networkLine(LtlStrings strings) {
    final ip = _status.ipAddress;
    if (ip == null) return strings.notAvailable;
    final port = _status.tcpPort ?? 0;
    if (port > 0) return '$ip:$port';
    if (_status.wifiAdbEnabled == true) return '$ip (${strings.wirelessPortHint})';
    return '$ip, ${strings.networkAdbOff}';
  }

  Future<void> _showGrantDialog() {
    final strings = LtlStrings.of(context);
    final command = _status.grantCommand;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.controlPermission),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.grantExplanation),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(command, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
              ),
              const SizedBox(height: 12),
              Text(strings.grantAfterHint, style: Theme.of(dialogContext).textTheme.bodySmall),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              LtlSystem.openDeveloperSettings();
            },
            child: Text(strings.openDeveloperOptions),
          ),
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(strings.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = LtlStrings.of(context);
    final textTheme = Theme.of(context).textTheme;
    final status = _status;
    final device = _device;
    String onOff(bool value) => value ? strings.enabled : strings.disabled;

    return Column(
      children: [
        Text(strings.developer, style: textTheme.titleLarge),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusCard(
                  title: '${strings.adbStatus}: ${_loading ? strings.loading : onOff(status.adbEnabled)}',
                  active: status.adbEnabled,
                  lines: [
                    _InfoLine(label: strings.connectAddress, value: _networkLine(strings)),
                    _InfoLine(label: strings.developerOptions, value: onOff(status.developerOptionsEnabled)),
                    _InfoLine(
                      label: strings.permission,
                      value: status.canWriteSecureSettings ? strings.granted : strings.notGranted,
                    ),
                  ],
                ),
                FocusableSettingsTile(
                  autofocus: true,
                  leading: const Icon(Icons.usb),
                  title: _TileTitle(title: strings.adbDebugging, subtitle: strings.adbDebuggingHint),
                  trailing: _StatusSwitch(value: status.adbEnabled),
                  onPressed: _toggleAdb,
                ),
                if (status.supportsWifiAdb)
                  FocusableSettingsTile(
                    leading: const Icon(Icons.wifi),
                    title: _TileTitle(title: strings.wifiDebugging, subtitle: strings.wifiDebuggingHint),
                    trailing: _StatusSwitch(value: status.wifiAdbEnabled == true),
                    onPressed: _toggleWifiAdb,
                  ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.speed),
                  title: _TileTitle(title: strings.animationScale, subtitle: strings.animationScaleHint),
                  trailing: Text(_animationLabel(strings), style: textTheme.bodyMedium),
                  onPressed: _cycleAnimationScale,
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.vpn_key_outlined),
                  title: _TileTitle(
                    title: strings.controlPermission,
                    subtitle: status.canWriteSecureSettings ? strings.granted : strings.notGranted,
                  ),
                  trailing: Icon(
                    status.canWriteSecureSettings ? Icons.check_circle : Icons.error_outline,
                    color: status.canWriteSecureSettings ? Colors.greenAccent : Colors.orangeAccent,
                  ),
                  onPressed: _showGrantDialog,
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.developer_mode),
                  title: Text(strings.openDeveloperOptions, style: textTheme.bodyMedium),
                  onPressed: LtlSystem.openDeveloperSettings,
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.refresh),
                  title: Text(strings.refreshStatus, style: textTheme.bodyMedium),
                  onPressed: _refresh,
                ),
                if (device != null)
                  FocusableSettingsTile(
                    leading: const Icon(Icons.info_outline),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(strings.deviceInfo, style: textTheme.bodyMedium),
                        const SizedBox(height: 6),
                        _InfoLine(label: strings.model, value: device.displayName),
                        _InfoLine(label: 'Android', value: '${device.androidVersion} (API ${device.sdkInt})'),
                        _InfoLine(label: strings.build, value: device.buildId),
                        _InfoLine(label: 'YaOS', value: device.isYaOs ? strings.detected : strings.notDetected),
                        _InfoLine(label: strings.ipAddress, value: device.ipAddress ?? strings.notAvailable),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final bool active;
  final List<Widget> lines;

  const _StatusCard({required this.title, required this.active, required this.lines});

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.greenAccent : Colors.redAccent;
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(active ? Icons.check_circle : Icons.cancel, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall)),
            ],
          ),
          const SizedBox(height: 8),
          ...lines,
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: Text(label, style: style?.copyWith(color: Colors.white60))),
          const SizedBox(width: 8),
          Expanded(flex: 6, child: Text(value, style: style, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _TileTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _TileTitle({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hint = subtitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: textTheme.bodyMedium),
        if (hint != null && hint.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(hint, style: textTheme.bodySmall?.copyWith(color: Colors.white60)),
          ),
      ],
    );
  }
}

/// Switch that only shows the state: the tile itself handles the D-pad press.
class _StatusSwitch extends StatelessWidget {
  final bool value;

  const _StatusSwitch({required this.value});

  @override
  Widget build(BuildContext context) => ExcludeFocus(
        child: IgnorePointer(
          child: Switch(value: value, onChanged: (_) {}),
        ),
      );
}
