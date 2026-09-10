/*
 * FLauncher
 * Copyright (C) 2026 LeanBitLab
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

import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/models/app.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/notifications_service.dart';
import 'package:flauncher/widgets/rounded_switch_list_tile.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BlockedNotificationsPage extends StatelessWidget {
  static const String routeName = "blocked_notifications_panel";

  const BlockedNotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Consumer2<NotificationsService, AppsService>(
      builder: (context, notificationsService, appsService, _) {
        final blockedPackages = notificationsService.blockedPackages;
        final allApps = List<App>.from(appsService.applications)
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        final blockedApps = allApps.where((a) => blockedPackages.contains(a.packageName)).toList();
        final knownBlockedPkg = blockedApps.map((a) => a.packageName).toSet();
        final unknownBlockedPkg = blockedPackages.where((p) => !knownBlockedPkg.contains(p)).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: Row(
                children: [
                  Text(
                    localizations.blockedNotificationApps,
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  // --- SECTION 1: BLOCKED APPS ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                    child: Text(
                      "${localizations.blockedNotificationApps} (${blockedPackages.length})",
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (blockedPackages.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_active_outlined, color: Colors.green, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations.noBlockedApps,
                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    localizations.noBlockedAppsDesc,
                                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    ...blockedApps.map((app) => FocusableSettingsTile(
                          leading: FutureBuilder<dynamic>(
                            future: appsService.getAppIcon(app.packageName),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.memory(
                                    snapshot.data,
                                    width: 32,
                                    height: 32,
                                  ),
                                );
                              }
                              return const Icon(Icons.android, size: 32);
                            },
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(app.name, style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 2),
                              Text(
                                localizations.notificationsBlocked,
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.redAccent),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock_open, size: 14, color: Colors.redAccent),
                                const SizedBox(width: 4),
                                Text(
                                  localizations.unblockAppNotifications,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onPressed: () => notificationsService.unblockPackage(app.packageName),
                        )),
                    ...unknownBlockedPkg.map((pkg) => FocusableSettingsTile(
                          leading: const Icon(Icons.android, size: 32),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(pkg, style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 2),
                              Text(
                                localizations.notificationsBlocked,
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.redAccent),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock_open, size: 14, color: Colors.redAccent),
                                const SizedBox(width: 4),
                                Text(
                                  localizations.unblockAppNotifications,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onPressed: () => notificationsService.unblockPackage(pkg),
                        )),
                    FocusableSettingsTile(
                      leading: const Icon(Icons.clear_all, color: Colors.orange),
                      title: Text(
                        localizations.unblockAll,
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.orange),
                      ),
                      onPressed: () => notificationsService.unblockAllPackages(),
                    ),
                  ],

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),

                  // --- SECTION 2: ALL APPLICATIONS ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.applications,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          localizations.noBlockedAppsDesc,
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  ...allApps.map((app) {
                    final isBlocked = blockedPackages.contains(app.packageName);

                    return RoundedSwitchListTile(
                      value: !isBlocked,
                      onChanged: (allowed) {
                        if (allowed) {
                          notificationsService.unblockPackage(app.packageName);
                        } else {
                          notificationsService.blockPackage(app.packageName);
                        }
                      },
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(app.name, style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 2),
                          Text(
                            isBlocked ? localizations.notificationsBlocked : localizations.notificationsAllowed,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isBlocked ? Colors.redAccent : Colors.white54,
                            ),
                          ),
                        ],
                      ),
                      secondary: FutureBuilder<dynamic>(
                        future: appsService.getAppIcon(app.packageName),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.memory(
                                snapshot.data,
                                width: 32,
                                height: 32,
                              ),
                            );
                          }
                          return const Icon(Icons.android, size: 32);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
