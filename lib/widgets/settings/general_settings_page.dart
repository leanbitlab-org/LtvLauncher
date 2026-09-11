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
import 'package:flauncher/l10n/app_localizations.dart';
import 'focusable_settings_tile.dart';
import 'date_time_format_page.dart';
import 'back_button_action_page.dart';
import 'data_usage_period_page.dart';
import 'backup_restore_page.dart';
import 'app_language_page.dart';
import 'app_sort_priority_page.dart';

class GeneralSettingsPage extends StatelessWidget {
  static const String routeName = "general_settings_panel";

  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(localizations.system, style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                FocusableSettingsTile(
                  autofocus: true,
                  leading: const Icon(Icons.language),
                  title: Text(localizations.appLanguage, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(AppLanguagePage.routeName),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.sort),
                  title: Text(localizations.appSortPriority, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(AppSortPriorityPage.routeName),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.date_range),
                  title: Text(localizations.dateAndTimeFormat, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(DateTimeFormatPage.routeName),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.arrow_back),
                  title: Text(localizations.backButtonAction, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(BackButtonActionPage.routeName),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.data_usage),
                  title: Text(localizations.dataUsagePeriod, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(DataUsagePeriodPage.routeName),
                ),
                FocusableSettingsTile(
                  leading: const Icon(Icons.settings_backup_restore),
                  title: Text(localizations.backupAndRestore, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(BackupRestorePage.routeName),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
