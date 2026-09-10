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
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flauncher/flauncher_channel.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/providers/settings_service.dart';

class LTvLauncherAboutDialog extends StatelessWidget {
  final PackageInfo packageInfo;

  const LTvLauncherAboutDialog({
    Key? key,
    required this.packageInfo,
  }) : super(key: key);

  Color _hexToColor(String hex) {
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = context.watch<SettingsService>();
    final accentColor = _hexToColor(settingsService.accentColorHex);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        width: 360,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E28),
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
              // Clean App Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/icon.png",
                  height: 64,
                  width: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),

              // Title & Version
              const Text(
                "LTvLauncher",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "v${packageInfo.version} (${packageInfo.buildNumber})",
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Developed by LeanBitLab",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),

              // Sponsor Button
              _AboutButton(
                icon: Icons.favorite,
                iconColor: const Color(0xFFE91E63),
                label: "Sponsor Project",
                accentColor: accentColor,
                autofocus: true,
                onPressed: () {
                  FLauncherChannel().openUrl("https://github.com/sponsors/LeanBitLab");
                },
              ),
              const SizedBox(height: 8),

              // Source Code Button
              _AboutButton(
                icon: Icons.code,
                iconColor: Colors.white70,
                label: "Source Code",
                accentColor: accentColor,
                onPressed: () {
                  FLauncherChannel().openUrl("https://github.com/leanbitlab-org/LtvLauncher");
                },
              ),
              const SizedBox(height: 12),

              // Close Action
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutButton extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color accentColor;
  final VoidCallback onPressed;
  final bool autofocus;

  const _AboutButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.accentColor,
    required this.onPressed,
    this.autofocus = false,
  });

  @override
  State<_AboutButton> createState() => _AboutButtonState();
}

class _AboutButtonState extends State<_AboutButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _focused ? widget.accentColor.withOpacity(0.2) : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _focused ? Colors.white : Colors.transparent,
                width: _focused ? 2 : 0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 16, color: _focused ? Colors.white : widget.iconColor),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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
