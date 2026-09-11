/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
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

import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/settings/continue_watching_settings_page.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flauncher/widgets/settings/launcher_section_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/l10n/app_localizations.dart';

import '../../models/category.dart';

class LauncherSectionsPanelPage extends StatefulWidget {
  static const String routeName = "launcher_sections_panel";

  @override
  State<LauncherSectionsPanelPage> createState() => _LauncherSectionsPanelPageState();
}

class _LauncherSectionsPanelPageState extends State<LauncherSectionsPanelPage> {
  LauncherSection? _movingSection;
  late AppsService _appsService;
  final Map<Object, FocusNode> _focusNodes = {};
  DateTime? _lastMoveTime;
  final ContinueWatchingSection _continueWatchingSection = ContinueWatchingSection();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appsService = Provider.of<AppsService>(context, listen: false);
  }

  FocusNode _getFocusNode(LauncherSection section) {
    final key = ObjectKey(section);
    return _focusNodes.putIfAbsent(key, () => FocusNode());
  }

  @override
  void dispose() {
    _appsService.persistSectionsOrder();
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  List<LauncherSection> _getDisplaySections(List<LauncherSection> appSections, SettingsService? settingsService) {
    final list = List<LauncherSection>.from(appSections);
    if (settingsService != null) {
      final cwOrder = settingsService.continueWatchingOrder.clamp(0, list.length);
      _continueWatchingSection.order = cwOrder;
      list.insert(cwOrder, _continueWatchingSection);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    final settingsService = Provider.of<SettingsService?>(context);

    return Column(
      children: [
        Text(localizations.launcherSections, style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        Consumer<AppsService>(
          builder: (_, service, __) {
            final displaySections = _getDisplaySections(service.launcherSections, settingsService);

            return Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                cacheExtent: 1000,
                itemCount: displaySections.length,
                itemBuilder: (context, index) {
                  final section = displaySections[index];
                  return _section(context, section, index, displaySections.length, displaySections, settingsService);
                },
              ),
            );
          },
        ),
        const SizedBox(height: 4, width: 0),
        FocusableSettingsTile(
          leading: const Icon(Icons.add),
          title: Text(localizations.addSection, style: Theme.of(context).textTheme.bodyMedium),
          onPressed: () {
            Navigator.pushNamed(context, LauncherSectionPanelPage.routeName);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20, color: Colors.white70),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select with ◄ / ► then use ▲ / ▼ to reorder',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _section(
    BuildContext context,
    LauncherSection section,
    int index,
    int totalCount,
    List<LauncherSection> displaySections,
    SettingsService? settingsService,
  ) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String title = localizations.spacer;
    if (section is ContinueWatchingSection) {
      title = localizations.continueWatching;
    } else if (section is Category) {
      title = section.name;

      if (title == localizations.spacer) {
        title = localizations.disambiguateCategoryTitle(title);
      }
    }

    final bool isMoving = _movingSection == section;
    final focusNode = _getFocusNode(section);

    return Padding(
      key: ObjectKey(section),
      padding: const EdgeInsets.only(bottom: 12),
      child: Focus(
        focusNode: focusNode,
        onFocusChange: (focused) {
          if (focused && focusNode.context != null) {
            Scrollable.ensureVisible(
              focusNode.context!,
              alignment: 0.5,
              duration: const Duration(milliseconds: 100),
            );
          }
        },
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;

          if (isMoving) {
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _moveSection(section, -1, displaySections, settingsService);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _moveSection(section, 1, displaySections, settingsService);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.gameButtonA ||
                event.logicalKey == LogicalKeyboardKey.escape ||
                event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _endMove();
              return KeyEventResult.handled;
            }
          } else {
            // Not Moving
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                event.logicalKey == LogicalKeyboardKey.arrowRight) {
              setState(() {
                _movingSection = section;
              });
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.gameButtonA) {
              if (section is ContinueWatchingSection) {
                Navigator.pushNamed(context, ContinueWatchingSettingsPage.routeName);
              } else {
                final idx = _appsService.launcherSections.indexOf(section);
                Navigator.pushNamed(context, LauncherSectionPanelPage.routeName, arguments: idx);
              }
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Builder(builder: (context) {
            final bool focused = Focus.of(context).hasFocus;
            
            // Determine colors based on state
            final Color backgroundColor = isMoving 
                ? colorScheme.primaryContainer 
                : (focused ? Colors.white10 : Colors.transparent);
            
            final Color textColor = isMoving 
                ? colorScheme.onPrimaryContainer 
                : (focused ? Colors.white : Colors.white70);
            
            final Color iconColor = isMoving 
                ? colorScheme.onPrimaryContainer 
                : (focused ? colorScheme.primary : Colors.white38);

            return GestureDetector(
              onTap: () {
                if (isMoving) {
                  _endMove();
                } else {
                  if (section is ContinueWatchingSection) {
                    Navigator.pushNamed(context, ContinueWatchingSettingsPage.routeName);
                  } else {
                    final idx = _appsService.launcherSections.indexOf(section);
                    Navigator.pushNamed(context, LauncherSectionPanelPage.routeName, arguments: idx);
                  }
                }
              },
              onLongPress: () {
                if (!isMoving) {
                  setState(() {
                    _movingSection = section;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (focused || isMoving) ? colorScheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    // Drag Handle Icon
                    Icon(
                      isMoving ? Icons.drag_indicator : Icons.drag_handle,
                      color: iconColor,
                    ),
                    const SizedBox(width: 16),
                    
                    // Section Title
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: focused || isMoving ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    
                    // Move Indicators
                    if (isMoving) ...[
                      Icon(Icons.keyboard_arrow_up, color: textColor),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, color: textColor),
                    ] else ...[
                      const Icon(Icons.chevron_right, color: Colors.white24),
                    ],
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  void _moveSection(
    LauncherSection movingSection,
    int direction,
    List<LauncherSection> displaySections,
    SettingsService? settingsService,
  ) {
    final now = DateTime.now();
    if (_lastMoveTime != null && now.difference(_lastMoveTime!) < const Duration(milliseconds: 60)) {
      return;
    }
    _lastMoveTime = now;

    final currentIndex = displaySections.indexOf(movingSection);
    if (currentIndex == -1) return;
    final newIndex = currentIndex + direction;
    if (newIndex < 0 || newIndex >= displaySections.length) return;

    final otherSection = displaySections[newIndex];
    if (movingSection is ContinueWatchingSection) {
      settingsService?.setContinueWatchingOrder(newIndex);
    } else if (otherSection is ContinueWatchingSection) {
      settingsService?.setContinueWatchingOrder(currentIndex);
    } else {
      final appSections = _appsService.launcherSections;
      final oldAppIndex = appSections.indexOf(movingSection);
      final newAppIndex = appSections.indexOf(otherSection);
      if (oldAppIndex != -1 && newAppIndex != -1) {
        _appsService.moveSectionInMemory(oldAppIndex, newAppIndex);
      }
    }

    setState(() {
      _movingSection = movingSection;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _getFocusNode(movingSection).requestFocus();
      }
    });
  }

  void _endMove() {
    _appsService.persistSectionsOrder();
    setState(() {
      _movingSection = null;
    });
  }
}
