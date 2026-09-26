import 'package:flauncher/fork/jellyfin_service.dart';
import 'package:flauncher/models/watch_next_program.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/watch_next_service.dart';
import 'package:flauncher/widgets/continue_watching_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Fork: "Next Up" and "Recently Added" rows from Jellyfin, rendered with the
/// Continue Watching card. Shown directly under Continue Watching.
class JellyfinRows extends StatelessWidget {
  const JellyfinRows({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer4<JellyfinService, WatchNextService, AppsService, SettingsService>(
      builder: (context, jellyfin, watchNext, apps, settings, _) {
        if (!jellyfin.configured) return const SizedBox.shrink();

        // Don't repeat shows that Continue Watching already has.
        final continuing = watchNext.programs.map((p) => p.title.trim().toLowerCase()).toSet();
        final nextUp = jellyfin.nextUp.where((p) => !continuing.contains(p.title.trim().toLowerCase())).toList();
        final hidden = settings.hiddenWatchNextProgramIds;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row(context, 'Next Up', nextUp.where((p) => !hidden.contains(p.id.toString())).toList(), watchNext, apps, settings),
            _row(context, 'Recently Added',
                jellyfin.recentlyAdded.where((p) => !hidden.contains(p.id.toString())).toList(), watchNext, apps, settings),
          ],
        );
      },
    );
  }

  Widget _row(BuildContext context, String title, List<WatchNextProgram> programs, WatchNextService watchNext,
      AppsService apps, SettingsService settings) {
    if (programs.isEmpty) return const SizedBox.shrink();

    double cardHeight;
    final int? customHeight = int.tryParse(settings.continueWatchingCardSize);
    if (customHeight != null) {
      cardHeight = customHeight.toDouble();
    } else {
      switch (settings.continueWatchingCardSize) {
        case 'compact':
          cardHeight = 112.0;
          break;
        case 'large':
          cardHeight = 157.0;
          break;
        default:
          cardHeight = 135.0;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (settings.showCategoryTitles)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      shadows: const [Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•  ${programs.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: cardHeight + 36.0,
            child: ListView.builder(
              clipBehavior: Clip.none,
              padding: const EdgeInsets.all(8),
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: programs.length,
              itemBuilder: (context, index) {
                final program = programs[index];
                return Padding(
                  key: ValueKey(program.id),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: RepaintBoundary(
                    child: WatchNextCard(
                      program: program,
                      appsService: apps,
                      watchNextService: watchNext,
                      handleUpNavigationToSettings: false,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
