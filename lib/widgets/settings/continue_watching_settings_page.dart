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

    String sizeLabel;
    switch (settingsService.continueWatchingCardSize) {
      case 'compact':
        sizeLabel = 'Compact (200x112)';
        break;
      case 'large':
        sizeLabel = 'Large (280x157)';
        break;
      case 'normal':
      default:
        sizeLabel = 'Standard (240x135)';
        break;
    }

    final maxItems = settingsService.continueWatchingMaxItems;
    final maxItemsLabel = maxItems <= 0 ? 'Unlimited' : maxItems.toString();

    final hiddenCount = settingsService.hiddenWatchNextProgramIds.length +
        settingsService.hiddenWatchNextPackages.length;

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
              if (settingsService.showContinueWatching) ...[
                const SizedBox(height: 8),
                // Card Size
                FocusableSettingsTile(
                  leading: const Icon(Icons.aspect_ratio_outlined),
                  title: const Text('Card Size'),
                  trailing: Text(sizeLabel, style: const TextStyle(color: Colors.white70)),
                  onPressed: () => _showCardSizeDialog(context, settingsService),
                ),
                // Max items
                FocusableSettingsTile(
                  leading: const Icon(Icons.format_list_numbered_outlined),
                  title: const Text('Maximum Items'),
                  trailing: Text(maxItemsLabel, style: const TextStyle(color: Colors.white70)),
                  onPressed: () => _showMaxItemsDialog(context, settingsService),
                ),
                // Show progress bar
                RoundedSwitchListTile(
                  value: settingsService.continueWatchingShowProgress,
                  onChanged: (v) => settingsService.setContinueWatchingShowProgress(v),
                  title: const Text('Playback Progress Bar'),
                  secondary: const Icon(Icons.linear_scale_outlined),
                ),
                // Show description
                RoundedSwitchListTile(
                  value: settingsService.continueWatchingShowDescription,
                  onChanged: (v) => settingsService.setContinueWatchingShowDescription(v),
                  title: const Text('Episode & Video Details'),
                  secondary: const Icon(Icons.subtitles_outlined),
                ),
                // Hidden content manager
                if (hiddenCount > 0)
                  FocusableSettingsTile(
                    leading: const Icon(Icons.visibility_off_outlined),
                    title: const Text('Hidden Items & Apps'),
                    trailing: Text('$hiddenCount hidden', style: const TextStyle(color: Colors.orangeAccent)),
                    onPressed: () => _showHiddenContentDialog(context, settingsService, watchNextService),
                  ),
              ],
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
              // App Integration Tips
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 18, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('App Integration Tips',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• SmartTube: In SmartTube, open Settings → General → Channels → enable "Watch Next" to display paused videos here.\n'
                      '• Breezy Weather: In Breezy Weather, open Settings → Integration / Broadcast → enable "Gadgetbridge broadcast" for real-time background status bar weather updates.',
                      style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  void _showCardSizeDialog(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Card Size'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                settings.setContinueWatchingCardSize('compact');
                Navigator.of(context).pop();
              },
              child: const Text('Compact (200 × 112)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                settings.setContinueWatchingCardSize('normal');
                Navigator.of(context).pop();
              },
              child: const Text('Standard (240 × 135)'),
            ),
            SimpleDialogOption(
              onPressed: () {
                settings.setContinueWatchingCardSize('large');
                Navigator.of(context).pop();
              },
              child: const Text('Cinematic Large (280 × 157)'),
            ),
          ],
        );
      },
    );
  }

  void _showMaxItemsDialog(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Maximum Items'),
          children: [
            for (final count in [5, 10, 15, 20, 0])
              SimpleDialogOption(
                onPressed: () {
                  settings.setContinueWatchingMaxItems(count);
                  Navigator.of(context).pop();
                },
                child: Text(count == 0 ? 'Unlimited' : '$count items'),
              ),
          ],
        );
      },
    );
  }

  void _showHiddenContentDialog(BuildContext context, SettingsService settings, WatchNextService watchNext) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hidden Content'),
          content: Text(
            'You have ${settings.hiddenWatchNextProgramIds.length} hidden program(s) and '
            '${settings.hiddenWatchNextPackages.length} hidden app(s).\n\n'
            'Would you like to restore all hidden items to Continue Watching?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await settings.clearAllHiddenWatchNext();
                await watchNext.refresh();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Restore All'),
            ),
          ],
        );
      },
    );
  }
}
