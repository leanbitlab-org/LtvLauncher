/*
 * FLauncher
 * Copyright (C) 2024 LeanBitLab
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/watch_next_service.dart';
import 'package:flauncher/widgets/rounded_switch_list_tile.dart';
import 'focusable_settings_tile.dart';

class ContinueWatchingSettingsPage extends StatefulWidget {
  static const String routeName = "continue_watching_settings_panel";

  const ContinueWatchingSettingsPage({super.key});

  @override
  State<ContinueWatchingSettingsPage> createState() => _ContinueWatchingSettingsPageState();
}

class _ContinueWatchingSettingsPageState extends State<ContinueWatchingSettingsPage> with WidgetsBindingObserver {
  String _packageName = 'com.leanbitlab.ltvL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() {
          _packageName = info.packageName;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WatchNextService>().refresh();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<WatchNextService>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final settingsService = context.watch<SettingsService>();
    final watchNextService = context.watch<WatchNextService>();

    return Column(
      children: [
        Text(localizations.continueWatching, style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              RoundedSwitchListTile(
                autofocus: true,
                value: settingsService.showContinueWatching,
                onChanged: (value) async {
                  if (value) {
                    final hasPermission = await watchNextService.checkPermission();
                    if (!context.mounted) return;
                    if (!hasPermission) {
                      final granted = await watchNextService.requestPermission();
                      if (!context.mounted) return;
                      if (!granted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(localizations.permissionDeniedContinueWatching),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  }
                  settingsService.setShowContinueWatching(value);
                },
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(localizations.showContinueWatchingOnHome, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 2),
                    Text(
                      localizations.continueWatchingDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
                secondary: const Icon(Icons.play_circle_outline),
              ),
              const SizedBox(height: 12),
              FocusableSettingsTile(
                leading: const Icon(Icons.security),
                title: Text(localizations.notificationAccess.replaceAll('Notification', 'Watch Next'), style: Theme.of(context).textTheme.bodyMedium),
                trailing: Text(
                  watchNextService.hasPermission ? localizations.granted : localizations.permissionRequired,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: watchNextService.hasPermission ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  final has = await watchNextService.checkPermission();
                  if (!has && context.mounted) {
                    await watchNextService.requestPermission();
                  }
                },
              ),
              if (!watchNextService.hasPermission) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.continueWatchingPermissionDesc,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: SelectableText(
                          'adb shell pm grant $_packageName com.android.providers.tv.permission.READ_WRITE_WATCH_NEXT_PROGRAMS',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: Text(localizations.requestPermission),
                          onPressed: () => watchNextService.requestPermission(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
