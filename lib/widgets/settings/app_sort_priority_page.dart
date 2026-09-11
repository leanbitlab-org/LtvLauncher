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
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppSortPriorityPage extends StatelessWidget {
  static const String routeName = "app_sort_priority_panel";

  const AppSortPriorityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Consumer<SettingsService>(
      builder: (context, service, _) {
        return Column(
          children: [
            Text(localizations.appSortPriority, style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  _radioTile(
                    context,
                    service,
                    localizations.tvAppsFirst,
                    localizations.tvAppsFirstDesc,
                    APP_SORT_TV_FIRST,
                    autofocus: true,
                  ),
                  _radioTile(
                    context,
                    service,
                    localizations.nonTvAppsFirst,
                    localizations.nonTvAppsFirstDesc,
                    APP_SORT_NON_TV_FIRST,
                  ),
                  _radioTile(
                    context,
                    service,
                    localizations.noSortPriority,
                    localizations.noSortPriorityDesc,
                    APP_SORT_NONE,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _radioTile(
    BuildContext context,
    SettingsService service,
    String label,
    String description,
    String value, {
    bool autofocus = false,
  }) {
    final isSelected = service.appSortPriority == value;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    return FocusableSettingsTile(
      autofocus: autofocus,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? secondaryColor : Colors.grey,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60),
          ),
        ],
      ),
      onPressed: () {
        service.setAppSortPriority(value);
        context.read<AppsService>().setAppSortPriority(value);
      },
    );
  }
}
