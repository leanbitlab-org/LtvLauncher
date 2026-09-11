import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flauncher/models/watch_next_program.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/watch_next_service.dart';
import 'package:flauncher/widgets/side_panel_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WatchNextInfoPanel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = appsService.applications.firstWhereOrNull((a) => a.packageName == program.packageName);
    final appName = (app != null && app.name.isNotEmpty) ? app.name : program.packageName;

    return SidePanelDialog(
      width: 320,
      isRightSide: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: App icon + Title + Subtitle
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (appIconBytes != null)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.memory(appIconBytes!, fit: BoxFit.cover),
                  ),
                )
              else
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.play_circle_outline, color: Colors.white70),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.title,
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
          if (program.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              program.description,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. Play / Resume
                  TextButton(
                    autofocus: true,
                    onPressed: () {
                      Navigator.of(context).pop();
                      watchNextService.launch(program);
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Colors.greenAccent),
                        const SizedBox(width: 12),
                        Text('Play / Resume', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  // 2. Open App
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      if (app != null) {
                        await appsService.launchApp(app);
                      } else {
                        await watchNextService.launch(program);
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.open_in_new_rounded),
                        const SizedBox(width: 12),
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
                  // 3. Remove from Continue Watching
                  Consumer<SettingsService>(
                    builder: (context, settingsService, _) => TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await settingsService.hideWatchNextProgram(program.id);
                        await watchNextService.deleteProgram(program);
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_rounded, color: Colors.orangeAccent),
                          const SizedBox(width: 12),
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
                  // 4. Hide all from this app
                  Consumer<SettingsService>(
                    builder: (context, settingsService, _) => TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await settingsService.hideWatchNextPackage(program.packageName);
                        await watchNextService.refresh();
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.visibility_off_outlined, color: Colors.redAccent),
                          const SizedBox(width: 12),
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
                  // 5. App Info
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      if (app != null) {
                        await appsService.openAppInfo(app);
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded),
                        const SizedBox(width: 12),
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
