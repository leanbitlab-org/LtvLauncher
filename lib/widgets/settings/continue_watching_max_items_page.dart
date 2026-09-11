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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_service.dart';

class ContinueWatchingMaxItemsPage extends StatelessWidget {
  static const String routeName = "continue_watching_max_items_panel";

  const ContinueWatchingMaxItemsPage({super.key});

  static const List<(int, String, String)> maxItemsPresets = [
    (5, '5 Items', 'Display up to 5 recent items'),
    (10, '10 Items', 'Display up to 10 recent items'),
    (15, '15 Items', 'Display up to 15 recent items • Default'),
    (20, '20 Items', 'Display up to 20 recent items'),
    (0, 'Unlimited', 'Display all available items'),
  ];

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsService, int>(
      selector: (_, settingsService) => settingsService.continueWatchingMaxItems,
      builder: (context, currentCount, _) {
        final settingsService = context.read<SettingsService>();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: Row(
                children: [
                  Text(
                    'Maximum Items',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: maxItemsPresets.map((preset) {
                    final count = preset.$1;
                    final title = preset.$2;
                    final subtitle = preset.$3;
                    final isSelected = currentCount == count;

                    return _MaxItemsRadioTile(
                      title: title,
                      subtitle: subtitle,
                      value: count,
                      groupValue: currentCount,
                      isSelected: isSelected,
                      autofocus: isSelected,
                      onChanged: (value) {
                        if (value != null) {
                          settingsService.setContinueWatchingMaxItems(value);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MaxItemsRadioTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final int value;
  final int groupValue;
  final bool isSelected;
  final ValueChanged<int?> onChanged;
  final bool autofocus;

  const _MaxItemsRadioTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.isSelected,
    required this.onChanged,
    this.autofocus = false,
  });

  @override
  State<_MaxItemsRadioTile> createState() => _MaxItemsRadioTileState();
}

class _MaxItemsRadioTileState extends State<_MaxItemsRadioTile> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return RepaintBoundary(
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            widget.onChanged(widget.value);
            return null;
          }),
          ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: (_) {
            widget.onChanged(widget.value);
            return null;
          }),
        },
        child: Focus(
          autofocus: widget.autofocus,
          onFocusChange: (hasFocus) {
            setState(() {
              _hasFocus = hasFocus;
            });
            if (hasFocus) {
              Scrollable.ensureVisible(
                context,
                alignment: 0.5,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
              );
            }
          },
          child: InkWell(
            onTap: () {
              widget.onChanged(widget.value);
            },
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _hasFocus ? Colors.white.withOpacity(0.05) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: _hasFocus
                    ? Border.all(color: primaryColor, width: 2)
                    : Border.all(color: Colors.transparent, width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                                color: widget.isSelected ? Colors.white : Colors.white70,
                                fontSize: 14,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isSelected)
                    Icon(Icons.check_circle, color: primaryColor, size: 20)
                  else
                    const Icon(Icons.circle_outlined, color: Colors.white38, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
