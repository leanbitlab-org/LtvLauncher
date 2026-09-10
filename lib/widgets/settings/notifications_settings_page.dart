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
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/notifications_service.dart';
import 'focusable_settings_tile.dart';
import 'blocked_notifications_page.dart';

class NotificationsSettingsPage extends StatefulWidget {
  static const String routeName = "notifications_settings_panel";

  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final service = context.read<NotificationsService>();
        service.checkPermission();
        service.checkOverlayPermission();
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
      final service = context.read<NotificationsService>();
      service.checkPermission();
      service.checkOverlayPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(localizations.notifications, style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            child: Consumer<NotificationsService>(
              builder: (context, service, _) {
                return Column(
                  children: [
                    FocusableSettingsTile(
                      autofocus: true,
                      leading: const Icon(Icons.notifications_active_outlined),
                      title: Text(localizations.notificationAccess, style: Theme.of(context).textTheme.bodyMedium),
                      trailing: Text(
                        service.hasPermission ? localizations.granted : localizations.permissionRequired,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: service.hasPermission ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        await service.checkPermission();
                        if (!service.hasPermission) {
                          final success = await service.requestPermission();
                          if (!success && context.mounted) {
                            _showNotificationPermissionGuide(context);
                          }
                        }
                      },
                    ),
                    if (service.hasPermission) ...[
                      FocusableSettingsTile(
                        leading: const Icon(Icons.notifications_paused_outlined),
                        title: Text(localizations.hidePersistentNotifications, style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Text(
                          service.hidePersistentNotifications ? localizations.enabled : localizations.disabled,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: service.hidePersistentNotifications ? Colors.green : Colors.grey,
                          ),
                        ),
                        onPressed: () => service.setHidePersistentNotifications(!service.hidePersistentNotifications),
                      ),
                      FocusableSettingsTile(
                        leading: const Icon(Icons.block),
                        title: Text(localizations.blockedNotificationApps, style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Text(
                          service.blockedPackages.isEmpty ? '0' : '${service.blockedPackages.length}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: service.blockedPackages.isNotEmpty ? Colors.orange : Colors.grey,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pushNamed(BlockedNotificationsPage.routeName),
                      ),
                      FocusableSettingsTile(
                        leading: const Icon(Icons.picture_in_picture_alt_outlined),
                        title: Text(localizations.systemWidePopupAlert, style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Text(
                          !service.hasOverlayPermission
                              ? localizations.overlayPermissionRequired
                              : (service.systemPopupEnabled ? localizations.enabled : localizations.disabled),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: !service.hasOverlayPermission
                                ? Colors.orange
                                : (service.systemPopupEnabled ? Colors.green : Colors.grey),
                          ),
                        ),
                        onPressed: () async {
                          await service.checkOverlayPermission();
                          if (!service.hasOverlayPermission) {
                            final success = await service.requestOverlayPermission();
                            if (!success && context.mounted) {
                              _showOverlayPermissionGuide(context);
                            }
                          } else {
                            await service.setSystemPopupEnabled(!service.systemPopupEnabled);
                          }
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showNotificationPermissionGuide(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Access'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'On this device, the Notification Access settings screen could not be opened automatically.\n\n'
              'To enable notifications, grant permission manually via ADB from a computer connected to the TV:',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                'adb shell cmd notification allow_listener $packageName/$packageName.LauncherNotificationListenerService',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showOverlayPermissionGuide(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Overlay Permission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'On this device, the Overlay Permission settings screen could not be opened automatically.\n\n'
              'To enable overlay popups, grant permission manually via ADB from a computer connected to the TV:',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                'adb shell appops set $packageName SYSTEM_ALERT_WINDOW allow',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
