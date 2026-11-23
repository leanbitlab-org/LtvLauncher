import 'package:flutter/material.dart';

class FocusableSettingsTile extends StatefulWidget {
  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final bool autofocus;

  const FocusableSettingsTile({
    Key? key,
    required this.title,
    this.leading,
    this.trailing,
    this.onPressed,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<FocusableSettingsTile> createState() => _FocusableSettingsTileState();
}

class _FocusableSettingsTileState extends State<FocusableSettingsTile> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => widget.onPressed?.call()),
          ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: (_) => widget.onPressed?.call()),
        },
        child: Focus(
          autofocus: widget.autofocus,
          onFocusChange: (hasFocus) {
            setState(() => _focused = hasFocus);
            if (hasFocus) {
              Scrollable.ensureVisible(
                context,
                alignment: 0.5,
                duration: const Duration(milliseconds: 100),
              );
            }
          },
          child: GestureDetector(
            onTap: widget.onPressed,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _focused ? primary.withOpacity(0.14) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _focused ? primary : Colors.transparent, width: 2),
              ),
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    IconTheme.merge(
                      data: IconThemeData(color: _focused ? primary : null),
                      child: widget.leading!,
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(child: widget.title),
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 16),
                    widget.trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
