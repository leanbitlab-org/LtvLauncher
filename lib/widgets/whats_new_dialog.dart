import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/whats_new.dart';
import 'package:flauncher/widgets/settings/donate_dialog.dart';
import 'package:flutter/material.dart';

/// Compact post-update dialog: release notes, then a Support us button that
/// opens the existing [DonateDialog].
class WhatsNewDialog extends StatefulWidget {
  final WhatsNewData data;

  const WhatsNewDialog({super.key, required this.data});

  @override
  State<WhatsNewDialog> createState() => _WhatsNewDialogState();
}

class _WhatsNewDialogState extends State<WhatsNewDialog> {
  final _gotItFocus = FocusNode(debugLabel: 'whatsNewGotIt');

  WhatsNewData get data => widget.data;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_keepFocusInside);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_keepFocusInside);
    _gotItFocus.dispose();
    super.dispose();
  }

  // The home screen behind the dialog can grab focus while its apps load (D-pad
  // keys then go to the tiles and the dialog cannot be dismissed): pull focus
  // back whenever it leaves this route.
  void _keepFocusInside() {
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) return;
    final primary = FocusManager.instance.primaryFocus;
    if (primary == null || !primary.ancestors.contains(FocusScope.of(context))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _gotItFocus.requestFocus();
      });
    }
  }

  ButtonStyle _style(BuildContext context, {required bool filled}) {
    final primary = Theme.of(context).colorScheme.primary;
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(44)),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      side: WidgetStateProperty.resolveWith((states) => BorderSide(
            color: states.contains(WidgetState.focused)
                ? primary
                : (filled ? Colors.transparent : Colors.white24),
            width: 2,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(l.whatsNew, style: textTheme.titleLarge)),
                Text(data.version, style: textTheme.bodySmall?.copyWith(color: Colors.white60)),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final note in data.notes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•  "),
                            Expanded(child: Text(note, style: textTheme.bodyMedium)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: _style(context, filled: false),
              icon: const Icon(Icons.favorite, color: Color(0xFFE91E63), size: 18),
              label: Text(l.supportUs),
              onPressed: () => showDialog(context: context, builder: (_) => const DonateDialog()),
            ),
            const SizedBox(height: 8),
            FilledButton(
              focusNode: _gotItFocus,
              autofocus: true,
              style: _style(context, filled: true),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.gotIt),
            ),
          ],
        ),
      ),
    );
  }
}
