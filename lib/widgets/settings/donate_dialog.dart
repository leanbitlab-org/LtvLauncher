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
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flauncher/flauncher_channel.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/providers/settings_service.dart';

class DonateDialog extends StatefulWidget {
  const DonateDialog({Key? key}) : super(key: key);

  @override
  State<DonateDialog> createState() => _DonateDialogState();
}

class _DonateDialogState extends State<DonateDialog> {
  int _selectedOption = 0; // 0: Open Collective, 1: GitHub Sponsors

  static const String _openCollectiveUrl = "https://opencollective.com/leanbitlab-org";
  static const String _githubSponsorsUrl = "https://github.com/sponsors/LeanBitLab";

  Color _hexToColor(String hex) {
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = context.watch<SettingsService>();
    final accentColor = _hexToColor(settingsService.accentColorHex);

    final currentUrl = _selectedOption == 0 ? _openCollectiveUrl : _githubSponsorsUrl;
    final currentPlatform = _selectedOption == 0 ? "Open Collective" : "GitHub Sponsors";
    final currentBrandColor = _selectedOption == 0 ? const Color(0xFF1F6FEB) : const Color(0xFFEA4AAA);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        width: 440,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Heart Icon
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, color: Color(0xFFE91E63), size: 24),
                  SizedBox(width: 8),
                  Text(
                    "Support LTvLauncher",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "Scan with your phone camera to donate:",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Platform Selector Buttons (D-pad friendly)
              Row(
                children: [
                  Expanded(
                    child: _PlatformTabButton(
                      label: "Open Collective",
                      icon: Icons.volunteer_activism,
                      isSelected: _selectedOption == 0,
                      accentColor: accentColor,
                      autofocus: true,
                      onPressed: () => setState(() => _selectedOption = 0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PlatformTabButton(
                      label: "GitHub Sponsors",
                      icon: Icons.favorite_border,
                      isSelected: _selectedOption == 1,
                      accentColor: accentColor,
                      onPressed: () => setState(() => _selectedOption = 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // QR Code in high-contrast crisp white background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: currentUrl,
                  version: QrVersions.auto,
                  size: 170.0,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // URL and platform badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: currentBrandColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: currentBrandColor.withOpacity(0.5)),
                ),
                child: Text(
                  currentPlatform,
                  style: TextStyle(
                    color: currentBrandColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                currentUrl,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 12),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DialogActionButton(
                    icon: Icons.open_in_browser,
                    label: "Open in Browser",
                    accentColor: accentColor,
                    onPressed: () => FLauncherChannel().openUrl(currentUrl),
                  ),
                  const SizedBox(width: 12),
                  _DialogActionButton(
                    icon: Icons.close,
                    label: "Close",
                    accentColor: accentColor,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformTabButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onPressed;
  final bool autofocus;

  const _PlatformTabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    required this.onPressed,
    this.autofocus = false,
  });

  @override
  State<_PlatformTabButton> createState() => _PlatformTabButtonState();
}

class _PlatformTabButtonState extends State<_PlatformTabButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.isSelected
        ? widget.accentColor.withOpacity(0.3)
        : (_focused ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.05));

    final Color borderColor = _focused
        ? Colors.white
        : (widget.isSelected ? widget.accentColor : Colors.transparent);

    return Actions(
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => widget.onPressed()),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: (_) => widget.onPressed()),
      },
      child: Focus(
        autofocus: widget.autofocus,
        onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor,
                width: _focused ? 2 : (widget.isSelected ? 1.5 : 0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.isSelected ? Colors.white : Colors.white70,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: widget.isSelected || _focused ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onPressed;

  const _DialogActionButton({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onPressed,
  });

  @override
  State<_DialogActionButton> createState() => _DialogActionButtonState();
}

class _DialogActionButtonState extends State<_DialogActionButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => widget.onPressed()),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: (_) => widget.onPressed()),
      },
      child: Focus(
        onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _focused ? widget.accentColor.withOpacity(0.3) : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _focused ? Colors.white : Colors.transparent,
                width: _focused ? 2 : 0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 16, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: _focused ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
