import 'package:flauncher/models/watch_next_program.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/watch_next_service.dart';
import 'package:flauncher/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/l10n/app_localizations.dart';

class ContinueWatchingRow extends StatelessWidget {
  const ContinueWatchingRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    if (!settingsService.showContinueWatching) {
      return const SizedBox.shrink();
    }

    return Consumer2<WatchNextService, AppsService>(
      builder: (context, watchNextService, appsService, _) {
        if (!watchNextService.hasPermission) {
          return const SizedBox.shrink();
        }

        final List<WatchNextProgram> programs = watchNextService.programs
            .where((p) => !appsService.applications.any((app) => app.packageName == p.packageName && app.hidden))
            .toList();
        if (programs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  AppLocalizations.of(context)!.continueWatching,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    shadows: [
                      const Shadow(
                        color: Colors.black54,
                        offset: Offset(1, 1),
                        blurRadius: 8,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 170, // Increased for larger cards
                child: ListView.builder(
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.all(8),
                  scrollDirection: Axis.horizontal,
                  itemCount: programs.length,
                  itemBuilder: (context, index) {
                    final program = programs[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: WatchNextCard(
                        program: program,
                        appsService: appsService,
                        watchNextService: watchNextService,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WatchNextCard extends StatefulWidget {
  final WatchNextProgram program;
  final AppsService appsService;
  final WatchNextService watchNextService;

  const WatchNextCard({
    Key? key,
    required this.program,
    required this.appsService,
    required this.watchNextService,
  }) : super(key: key);

  @override
  State<WatchNextCard> createState() => _WatchNextCardState();
}

class _WatchNextCardState extends State<WatchNextCard> with SingleTickerProviderStateMixin {
  late final FocusNode _focusNode;
  bool _focused = false;
  Future<Uint8List>? _iconFuture;
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _iconFuture = widget.appsService.getAppIcon(widget.program.packageName);
  }

  @override
  void didUpdateWidget(covariant WatchNextCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.program.packageName != widget.program.packageName) {
      _iconFuture = widget.appsService.getAppIcon(widget.program.packageName);
    }
  }

  void _onFocusChange() {
    setState(() {
      _focused = _focusNode.hasFocus;
    });
    if (_focusNode.hasFocus) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 100),
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _animation.dispose();
    super.dispose();
  }

  void _onPressed() {
    widget.watchNextService.launch(widget.program);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String themes = context.select<SettingsService, String>((s) => s.themes);
    final String accentColorHex = context.select<SettingsService, String>((s) => s.accentColorHex);
    final bool appHighlightAnimationEnabled = context.select<SettingsService, bool>((s) => s.appHighlightAnimationEnabled);
    final bool hideHighlightOutlineOnHomescreen = context.select<SettingsService, bool>((s) => s.hideHighlightOutlineOnHomescreen);
    final bool appSelectorTransitionAnimationEnabled = context.select<SettingsService, bool>((s) => s.appSelectorTransitionAnimationEnabled);

    final Color accentColor = Color(int.parse('FF$accentColorHex', radix: 16));
    const cardWidth = 240.0;
    const cardHeight = 135.0;

    BorderRadius borderRadius;
    BorderRadius innerBorderRadius;

    switch (themes) {
      case 'premium':
        borderRadius = BorderRadius.circular(16);
        innerBorderRadius = BorderRadius.circular(14);
        break;
      case 'classic':
        borderRadius = BorderRadius.zero;
        innerBorderRadius = BorderRadius.zero;
        break;
      case 'capsule':
        borderRadius = BorderRadius.circular(100);
        innerBorderRadius = BorderRadius.circular(98);
        break;
      case 'modern':
      default:
        borderRadius = BorderRadius.circular(8);
        innerBorderRadius = BorderRadius.circular(6);
        break;
    }

    double scale = 1.0;
    if (_focused) {
      if (themes == 'premium') {
        scale = 1.15;
      } else if (themes == 'classic') {
        scale = 1.0;
      } else {
        scale = 1.1;
      }
    }

    final double elevation = _focused
        ? (themes == 'classic' ? 8 : 16)
        : 0;
    final Color shadowColor = Colors.black;

    Widget? highlightWidget;
    if (_focused && !hideHighlightOutlineOnHomescreen) {
      if (themes == 'premium') {
        _animation.stop();
      } else if (themes == 'classic') {
        _animation.stop();
        highlightWidget = IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(color: accentColor, width: 4),
            ),
          ),
        );
      } else if (appHighlightAnimationEnabled) {
        _animation.repeat(reverse: true);
        highlightWidget = AnimatedBuilder(
          animation: CurvedAnimation(parent: _animation, curve: Curves.easeInOut),
          builder: (context, child) {
            final opacity = 0.4 + (_animation.value * 0.6);
            return IgnorePointer(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      border: Border.all(
                        color: accentColor.withOpacity(opacity),
                        width: 2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: innerBorderRadius,
                        border: Border.all(
                          color: Colors.black.withOpacity(opacity),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        _animation.stop();
        highlightWidget = IgnorePointer(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(color: accentColor, width: 2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: innerBorderRadius,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      _animation.stop();
    }

    // Progress percentage
    double progress = 0;
    if (widget.program.duration > 0 && widget.program.playbackPosition >= 0) {
      progress = widget.program.playbackPosition / widget.program.duration;
      if (progress > 1.0) progress = 1.0;
    }

    return FocusableActionDetector(
      focusNode: _focusNode,
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => _onPressed(),
        ),
        MoveFocusToSettingsIntent: CallbackAction<MoveFocusToSettingsIntent>(
          onInvoke: (_) => Actions.invoke(context, const MoveFocusToSettingsIntent()),
        ),
      },
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): MoveFocusToSettingsIntent(),
      },
      child: GestureDetector(
        onTap: _onPressed,
        child: AnimatedContainer(
          duration: appSelectorTransitionAnimationEnabled
              ? const Duration(milliseconds: 200)
              : Duration.zero,
          curve: Curves.easeOutBack,
          width: cardWidth,
          height: cardHeight,
          transform: Matrix4.diagonal3Values(scale, scale, 1.0),
          transformAlignment: Alignment.center,
          child: Material(
            borderRadius: borderRadius,
            clipBehavior: Clip.antiAlias,
            elevation: elevation,
            shadowColor: shadowColor,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Poster background
                Positioned.fill(
                  child: (widget.program.posterBytes != null && widget.program.posterBytes!.isNotEmpty)
                      ? Image.memory(
                          widget.program.posterBytes!,
                          fit: BoxFit.cover,
                          cacheWidth: 480,
                          filterQuality: FilterQuality.medium,
                          errorBuilder: (context, error, stackTrace) => _emptyPosterFallback(theme),
                        )
                      : _emptyPosterFallback(theme),
                ),
                // App icon badge (top-right, glass effect)
                Positioned(
                  top: 8,
                  right: 8,
                  child: FutureBuilder<Uint8List>(
                    future: _iconFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 0.5,
                            ),
                          ),
                          padding: const EdgeInsets.all(3),
                          child: Image.memory(snapshot.data!),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                // Title + progress overlay (bottom)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.9),
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 28, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.program.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              const Shadow(
                                color: Colors.black87,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              )
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.program.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              widget.program.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white60,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (progress > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.white.withOpacity(0.15),
                                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${(progress * 100).round()}%',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white54,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (highlightWidget != null) highlightWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyPosterFallback(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade800,
          ],
        ),
      ),
      child: Center(
        child: FutureBuilder<Uint8List>(
          future: _iconFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Opacity(
                opacity: 0.4,
                child: Image.memory(snapshot.data!, width: 48, height: 48),
              );
            }
            return Icon(
              Icons.play_circle_outline,
              size: 48,
              color: Colors.white.withOpacity(0.15),
            );
          },
        ),
      ),
    );
  }
}
