import 'package:flauncher/actions.dart';
import 'package:flutter/material.dart';

class SidePanelDialog extends StatelessWidget {
  final Widget child;
  final double width;
  final bool isRightSide;

  const SidePanelDialog({
    required this.child,
    this.width = 250,
    this.isRightSide = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.horizontal(
      right: isRightSide ? Radius.zero : const Radius.circular(24),
      left: isRightSide ? const Radius.circular(24) : Radius.zero,
    );

    return Align(
      alignment: isRightSide ? Alignment.centerRight : Alignment.centerLeft,
      child: Material(
        color: const Color(0xFF1E1E1E),
        elevation: 24,
        shadowColor: Colors.black,
        borderRadius: borderRadius,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Actions(
            actions: { BackIntent: BackAction(context) },
            child: child,
          ),
        ),
      ),
    );
  }
}
