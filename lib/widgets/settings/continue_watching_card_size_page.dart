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

class ContinueWatchingCardSizePage extends StatelessWidget {
  static const String routeName = "continue_watching_card_size_panel";

  const ContinueWatchingCardSizePage({super.key});

  static const List<(int, String, String)> cardSizePresets = [
    (80, '80 dp • Extra Small', '142 × 80 dp (16:9)'),
    (90, '90 dp • Very Small', '160 × 90 dp (16:9)'),
    (100, '100 dp • Small', '178 × 100 dp (16:9)'),
    (110, '110 dp • Compact', '196 × 110 dp (16:9)'),
    (120, '120 dp • Medium Small', '213 × 120 dp (16:9)'),
    (130, '130 dp • Medium', '231 × 130 dp (16:9)'),
    (135, '135 dp • Standard (Default)', '240 × 135 dp (16:9)'),
    (140, '140 dp • Medium Large', '249 × 140 dp (16:9)'),
    (150, '150 dp • Large', '267 × 150 dp (16:9)'),
    (160, '160 dp • Very Large', '284 × 160 dp (16:9)'),
    (170, '170 dp • Extra Large', '302 × 170 dp (16:9)'),
    (180, '180 dp • Huge', '320 × 180 dp (16:9)'),
  ];

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsService, String>(
      selector: (_, settingsService) => settingsService.continueWatchingCardSize,
      builder: (context, currentSizeStr, _) {
        final settingsService = context.read<SettingsService>();
        final int currentHeight = int.tryParse(currentSizeStr) ??
            (currentSizeStr == 'compact' ? 112 : (currentSizeStr == 'large' ? 157 : 135));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: Row(
                children: [
                  Text(
                    'Card Size',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: cardSizePresets.map((preset) {
                    final height = preset.$1;
                    final title = preset.$2;
                    final subtitle = preset.$3;
                    final isSelected = currentHeight == height;

                    return _CardSizeRadioTile(
                      title: title,
                      subtitle: subtitle,
                      value: height.toString(),
                      groupValue: currentHeight.toString(),
                      isSelected: isSelected,
                      autofocus: isSelected,
                      onChanged: (value) {
                        if (value != null) {
                          settingsService.setContinueWatchingCardSize(value);
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

class _CardSizeRadioTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final bool isSelected;
  final ValueChanged<String?> onChanged;
  final bool autofocus;

  const _CardSizeRadioTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.isSelected,
    required this.onChanged,
    this.autofocus = false,
  });

  @override
  State<_CardSizeRadioTile> createState() => _CardSizeRadioTileState();
}

class _CardSizeRadioTileState extends State<_CardSizeRadioTile> {
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
