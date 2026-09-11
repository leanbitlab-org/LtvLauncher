import 'package:flauncher/models/watch_next_program.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/watch_next_service.dart';
import 'package:flauncher/actions.dart';
import 'package:flauncher/widgets/app_card_keys.dart';
import 'package:flauncher/widgets/focus_keyboard_listener.dart';
import 'package:flauncher/widgets/watch_next_info_panel.dart';
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

        final hiddenProgramIds = settingsService.hiddenWatchNextProgramIds;
        final hiddenPackages = settingsService.hiddenWatchNextPackages;

        List<WatchNextProgram> programs = watchNextService.programs
            .where((p) =>
                !hiddenProgramIds.contains(p.id.toString()) &&
                !hiddenPackages.contains(p.packageName) &&
                !appsService.applications.any((app) => app.packageName == p.packageName && app.hidden))
            .toList();

        final maxItems = settingsService.continueWatchingMaxItems;
        if (maxItems > 0 && programs.length > maxItems) {
          programs = programs.sublist(0, maxItems);
        }

        if (programs.isEmpty) {
          return const SizedBox.shrink();
        }

        double cardHeight;
        final int? customHeight = int.tryParse(settingsService.continueWatchingCardSize);
        if (customHeight != null) {
          cardHeight = customHeight.toDouble();
        } else {
          switch (settingsService.continueWatchingCardSize) {
            case 'compact':
              cardHeight = 112.0;
              break;
            case 'large':
              cardHeight = 157.0;
              break;
            case 'normal':
            default:
              cardHeight = 135.0;
              break;
          }
        }
        final double rowHeight = cardHeight + 36.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Row(
                  children: [
                    Text(
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
                height: rowHeight,
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
                          appsService: appsService,
                          watchNextService: watchNextService,
                        ),
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
  bool _clicked = false;
  Uint8List? _appIconBytes;
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _loadAppIcon();
  }

  Future<void> _loadAppIcon() async {
    try {
      final bytes = await widget.appsService.getAppIcon(widget.program.packageName);
      if (mounted && bytes.isNotEmpty) {
        setState(() => _appIconBytes = bytes);
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant WatchNextCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.program.packageName != widget.program.packageName) {
      _loadAppIcon();
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
    if (!_clicked) {
      setState(() => _clicked = true);
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        widget.watchNextService.launch(widget.program);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => _clicked = false);
          }
        });
      });
    }
  }

  void _onLongPress() {
    showDialog(
      context: context,
      builder: (context) => WatchNextInfoPanel(
        program: widget.program,
        watchNextService: widget.watchNextService,
        appsService: widget.appsService,
        appIconBytes: _appIconBytes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String themes = context.select<SettingsService, String>((s) => s.themes);
    final String accentColorHex = context.select<SettingsService, String>((s) => s.accentColorHex);
    final bool appHighlightAnimationEnabled = context.select<SettingsService, bool>((s) => s.appHighlightAnimationEnabled);
    final bool hideHighlightOutlineOnHomescreen = context.select<SettingsService, bool>((s) => s.hideHighlightOutlineOnHomescreen);
    final bool appSelectorTransitionAnimationEnabled = context.select<SettingsService, bool>((s) => s.appSelectorTransitionAnimationEnabled);
    final String cardSize = context.select<SettingsService, String>((s) => s.continueWatchingCardSize);
    final bool showProgress = context.select<SettingsService, bool>((s) => s.continueWatchingShowProgress);
    final bool showDescription = context.select<SettingsService, bool>((s) => s.continueWatchingShowDescription);

    final Color accentColor = Color(int.parse('FF$accentColorHex', radix: 16));
    double cardWidth;
    double cardHeight;
    final int? customHeight = int.tryParse(cardSize);
    if (customHeight != null) {
      cardHeight = customHeight.toDouble();
      cardWidth = (cardHeight * 16 / 9).roundToDouble();
    } else {
      switch (cardSize) {
        case 'compact':
          cardWidth = 200.0;
          cardHeight = 112.0;
          break;
        case 'large':
          cardWidth = 280.0;
          cardHeight = 157.0;
          break;
        case 'normal':
        default:
          cardWidth = 240.0;
          cardHeight = 135.0;
          break;
      }
    }

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

    return FocusKeyboardListener(
      onPressed: (key) {
        if (key == LogicalKeyboardKey.arrowUp) {
          Actions.invoke(context, const MoveFocusToSettingsIntent());
          return KeyEventResult.handled;
        } else if (AppCardKeys.validationKeys.contains(key)) {
          _onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      onLongPress: (key) {
        if (AppCardKeys.longPressableKeys.contains(key) || AppCardKeys.menuKeys.contains(key)) {
          _onLongPress();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      builder: (context) {
        return Actions(
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) => _onPressed(),
            ),
            ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
              onInvoke: (_) => _onPressed(),
            ),
          },
          child: Focus(
            focusNode: _focusNode,
            child: InkWell(
              canRequestFocus: false,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: _onPressed,
              onLongPress: _onLongPress,
              child: AnimatedScale(
              scale: _clicked ? 0.9 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: _clicked ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 150),
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
                          child: _buildPoster(theme),
                        ),
                        // App icon badge (top-right, glass effect)
                        if (_appIconBytes != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
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
                              child: Image.memory(_appIconBytes!),
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
                                if (showDescription && widget.program.description.isNotEmpty)
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
                                if (showProgress && progress > 0)
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
            ),
          ),
        ),
      );
    },
    );
  }

  Widget _buildPoster(ThemeData theme) {
    if (widget.program.posterBytes != null && widget.program.posterBytes!.isNotEmpty) {
      return Image.memory(
        widget.program.posterBytes!,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        errorBuilder: (context, error, stackTrace) => _emptyPosterFallback(theme),
      );
    }
    if (widget.program.posterArtUri.startsWith('http://') ||
        widget.program.posterArtUri.startsWith('https://')) {
      return Image.network(
        widget.program.posterArtUri,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        errorBuilder: (context, error, stackTrace) => _emptyPosterFallback(theme),
      );
    }
    return _emptyPosterFallback(theme);
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
        child: _appIconBytes != null
            ? Opacity(
                opacity: 0.4,
                child: Image.memory(_appIconBytes!, width: 48, height: 48),
              )
            : Icon(
                Icons.play_circle_outline,
                size: 48,
                color: Colors.white.withOpacity(0.15),
              ),
      ),
    );
  }
}
