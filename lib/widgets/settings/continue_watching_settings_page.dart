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

import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/apps_service.dart';
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
    final appsService = context.watch<AppsService>();

    String sizeLabel;
    final int? customHeight = int.tryParse(settingsService.continueWatchingCardSize);
    if (customHeight != null) {
      final w = (customHeight * 16 / 9).round();
      sizeLabel = '$customHeight dp ($w × $customHeight)';
    } else {
      switch (settingsService.continueWatchingCardSize) {
        case 'compact':
          sizeLabel = '112 dp (200 × 112)';
          break;
        case 'large':
          sizeLabel = '157 dp (280 × 157)';
          break;
        case 'normal':
        default:
          sizeLabel = '135 dp (240 × 135)';
          break;
      }
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
              // Apps with Continue Watching
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Apps with Continue Watching',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: const Text('Block other app'),
                    onPressed: () => _showBlockAppDialog(context, settingsService, appsService),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildAppsList(context, watchNextService, settingsService, appsService),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppsList(
    BuildContext context,
    WatchNextService watchNextService,
    SettingsService settingsService,
    AppsService appsService,
  ) {
    final activePackages = watchNextService.programs.map((p) => p.packageName).toSet();
    final blockedPackages = settingsService.hiddenWatchNextPackages.toSet();
    final allPackages = {...activePackages, ...blockedPackages}.toList();

    if (allPackages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: const Text(
          'No apps are currently providing Continue Watching items.\nWhen supported apps (such as SmartTube or streaming services) add items, they will appear here.',
          style: TextStyle(fontSize: 12, color: Colors.white60, height: 1.4),
        ),
      );
    }

    return Column(
      children: allPackages.map((pkg) {
        final app = appsService.applications.firstWhereOrNull((a) => a.packageName == pkg);
        final appName = (app != null && app.name.isNotEmpty) ? app.name : pkg;
        final isBlocked = blockedPackages.contains(pkg);
        final count = watchNextService.programs.where((p) => p.packageName == pkg).length;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isBlocked ? Colors.red.withOpacity(0.3) : Colors.white10,
            ),
          ),
          child: ListTile(
            leading: FutureBuilder<Uint8List>(
              future: appsService.getAppIcon(pkg),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.memory(snapshot.data!, width: 36, height: 36, fit: BoxFit.cover),
                  );
                }
                return const Icon(Icons.tv, size: 36);
              },
            ),
            title: Text(
              appName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isBlocked ? Colors.white54 : Colors.white,
              ),
            ),
            subtitle: Text(
              isBlocked
                  ? 'Blocked from Continue Watching'
                  : (count > 0 ? '$count active item(s)' : 'Active'),
              style: TextStyle(
                fontSize: 12,
                color: isBlocked ? Colors.redAccent : Colors.white60,
              ),
            ),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isBlocked ? Colors.green.shade700 : Colors.red.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: Icon(isBlocked ? Icons.check_circle_outline : Icons.block, size: 16),
              label: Text(isBlocked ? 'Unblock' : 'Block'),
              onPressed: () {
                if (isBlocked) {
                  settingsService.unhideWatchNextPackage(pkg);
                } else {
                  settingsService.hideWatchNextPackage(pkg);
                }
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showBlockAppDialog(
    BuildContext context,
    SettingsService settings,
    AppsService appsService,
  ) {
    final blocked = settings.hiddenWatchNextPackages.toSet();
    final candidateApps = appsService.applications
        .where((a) => !blocked.contains(a.packageName))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Block App from Continue Watching'),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: candidateApps.isEmpty
                ? const Center(child: Text('All installed apps are already blocked.'))
                : ListView.builder(
                    itemCount: candidateApps.length,
                    itemBuilder: (context, index) {
                      final app = candidateApps[index];
                      return ListTile(
                        leading: FutureBuilder<Uint8List>(
                          future: appsService.getAppIcon(app.packageName),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                              return Image.memory(snapshot.data!, width: 28, height: 28);
                            }
                            return const Icon(Icons.apps, size: 28);
                          },
                        ),
                        title: Text(app.name),
                        subtitle: Text(app.packageName, style: const TextStyle(fontSize: 11, color: Colors.white54)),
                        onTap: () {
                          settings.hideWatchNextPackage(app.packageName);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showCardSizeDialog(BuildContext context, SettingsService settings) {
    final sizes = [
      (80, '80 dp (142 × 80) • Extra Small'),
      (90, '90 dp (160 × 90) • Very Small'),
      (100, '100 dp (178 × 100) • Small'),
      (110, '110 dp (196 × 110) • Compact'),
      (120, '120 dp (213 × 120) • Medium Small'),
      (130, '130 dp (231 × 130) • Medium'),
      (135, '135 dp (240 × 135) • Standard (Default)'),
      (140, '140 dp (249 × 140) • Medium Large'),
      (150, '150 dp (267 × 150) • Large'),
      (160, '160 dp (284 × 160) • Very Large'),
      (170, '170 dp (302 × 170) • Extra Large'),
      (180, '180 dp (320 × 180) • Huge'),
    ];

    showDialog(
      context: context,
      builder: (context) {
        final currentSizeStr = settings.continueWatchingCardSize;
        final currentHeight = int.tryParse(currentSizeStr) ??
            (currentSizeStr == 'compact' ? 112 : (currentSizeStr == 'large' ? 157 : 135));

        return SimpleDialog(
          title: const Text('Select Card Size'),
          children: sizes.map((item) {
            final isSelected = currentHeight == item.$1;
            return SimpleDialogOption(
              onPressed: () {
                settings.setContinueWatchingCardSize(item.$1.toString());
                Navigator.of(context).pop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.$2,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            );
          }).toList(),
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
