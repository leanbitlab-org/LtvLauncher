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

import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flauncher/models/watch_next_program.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/watch_next_service.dart';
import 'package:flauncher/widgets/side_panel_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WatchNextInfoPanel extends StatefulWidget {
  final WatchNextProgram program;
  final WatchNextService watchNextService;
  final AppsService appsService;
  final Uint8List? appIconBytes;

  const WatchNextInfoPanel({
    Key? key,
    required this.program,
    required this.watchNextService,
    required this.appsService,
    this.appIconBytes,
  }) : super(key: key);

  @override
  State<WatchNextInfoPanel> createState() => _WatchNextInfoPanelState();
}

class _WatchNextInfoPanelState extends State<WatchNextInfoPanel> {
  late final DateTime _openedAt;

  @override
  void initState() {
    super.initState();
    _openedAt = DateTime.now();
  }

  bool get _canInteract => DateTime.now().difference(_openedAt) >= const Duration(milliseconds: 350);

  void _safeAction(VoidCallback action) {
    if (!_canInteract) return;
    action();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = widget.appsService.applications.firstWhereOrNull((a) => a.packageName == widget.program.packageName);
    final appName = (app != null && app.name.isNotEmpty) ? app.name : widget.program.packageName;

    return SidePanelDialog(
      width: 300,
      isRightSide: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: App icon + Title + Subtitle
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.appIconBytes != null && widget.appIconBytes!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    widget.appIconBytes!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.play_circle_outline, color: Colors.white70, size: 28),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.program.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.program.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              widget.program.description,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 6),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. Remove from Continue Watching
                  Consumer<SettingsService>(
                    builder: (context, settingsService, _) => TextButton(
                      onPressed: () => _safeAction(() async {
                        Navigator.of(context).pop();
                        await settingsService.hideWatchNextProgram(widget.program.id);
                        await widget.watchNextService.deleteProgram(widget.program);
                      }),
                      child: Row(
                        children: [
                          const Icon(Icons.visibility_off_outlined, color: Colors.orangeAccent),
                          Container(width: 8),
                          Expanded(
                            child: Text(
                              'Remove from Continue Watching',
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 2. Hide all from this app
                  Consumer<SettingsService>(
                    builder: (context, settingsService, _) => TextButton(
                      onPressed: () => _safeAction(() async {
                        Navigator.of(context).pop();
                        await settingsService.hideWatchNextPackage(widget.program.packageName);
                        await widget.watchNextService.refresh();
                      }),
                      child: Row(
                        children: [
                          const Icon(Icons.block, color: Colors.redAccent),
                          Container(width: 8),
                          Expanded(
                            child: Text(
                              'Hide all from $appName',
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 3. Play / Resume
                  TextButton(
                    onPressed: () => _safeAction(() {
                      Navigator.of(context).pop();
                      widget.watchNextService.launch(widget.program);
                    }),
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Colors.greenAccent),
                        Container(width: 8),
                        Text('Play / Resume', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  // 4. Open App
                  TextButton(
                    onPressed: () => _safeAction(() async {
                      Navigator.of(context).pop();
                      if (app != null) {
                        await widget.appsService.launchApp(app);
                      } else {
                        await widget.watchNextService.launch(widget.program);
                      }
                    }),
                    child: Row(
                      children: [
                        const Icon(Icons.open_in_new_rounded),
                        Container(width: 8),
                        Expanded(
                          child: Text(
                            'Open $appName',
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 5. App Info
                  TextButton(
                    onPressed: () => _safeAction(() async {
                      Navigator.of(context).pop();
                      if (app != null) {
                        await widget.appsService.openAppInfo(app);
                      }
                    }),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded),
                        Container(width: 8),
                        Text('App Info', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
