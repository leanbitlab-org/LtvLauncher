import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;
import 'package:flutter/widgets.dart';
import 'package:flauncher/flauncher_channel.dart';
import '../models/watch_next_program.dart';

class WatchNextService extends ChangeNotifier with WidgetsBindingObserver {
  final FLauncherChannel _channel;
  List<WatchNextProgram> _programs = [];
  bool _initialized = false;
  bool _hasPermission = true;
  Timer? _refreshTimer;
  StreamSubscription<dynamic>? _watchNextSubscription;
  int _callCount = 0;
  bool _isFetching = false;
  bool _hasPendingRefresh = false;

  bool get _isTest => Platform.environment.containsKey('FLUTTER_TEST');

  WatchNextService(this._channel) {
    if (!_isTest) {
      WidgetsBinding.instance.addObserver(this);
    }
    _init();
  }

  List<WatchNextProgram> get programs => List.unmodifiable(_programs);
  bool get initialized => _initialized;
  bool get hasPermission => _hasPermission;

  Future<void> _init() async {
    await refresh();
    _initialized = true;
    notifyListeners();

    try {
      _watchNextSubscription = _channel.addWatchNextChangedListener((_) {
        refresh();
      });
    } catch (e) {
      log('Failed to listen to watch next events', name: 'WatchNextService', error: e);
    }

    _startPeriodicTimer();
  }

  void _startPeriodicTimer() {
    _refreshTimer?.cancel();
    // Refresh fallback every 5 minutes (reactive ContentObserver handles real-time updates)
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) => refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _refreshTimer?.cancel();
      _refreshTimer = null;
    } else if (state == AppLifecycleState.resumed) {
      refresh();
      _startPeriodicTimer();
    }
  }

  Future<void> refresh() async {
    if (_isFetching) {
      _hasPendingRefresh = true;
      return;
    }
    _isFetching = true;

    final int callSnapshot = ++_callCount;
    try {
      final bool hasPermission = await checkPermission();
      if (callSnapshot != _callCount) return;

      _hasPermission = hasPermission;
      if (!hasPermission) {
        if (_programs.isNotEmpty) {
          _programs = [];
        }
        if (callSnapshot == _callCount) notifyListeners();
        return;
      }

      List<Map<dynamic, dynamic>> list;
      try {
        list = await _channel.getWatchNextPrograms();
      } catch (e) {
        log('Failed to fetch watch next programs', name: 'WatchNextService', error: e);
        list = const [];
      }
      if (callSnapshot != _callCount) return;

      // Phase 1: Emit programs immediately with cached posters where available
      final List<WatchNextProgram> newPrograms = [];
      for (final map in list) {
        final program = WatchNextProgram.fromMap(map);
        // Reuse existing poster bytes if same program already loaded
        final existing = _findExisting(program.id);
        if (existing != null && existing.posterBytes != null) {
          program.posterBytes = existing.posterBytes;
        }
        newPrograms.add(program);
      }

      // Explicitly sort programs so the most recently watched content is first
      newPrograms.sort((a, b) {
        int timeA = a.lastEngagementTime;
        int timeB = b.lastEngagementTime;
        if (timeA > 0 && timeA < 10000000000) timeA *= 1000;
        if (timeB > 0 && timeB < 10000000000) timeB *= 1000;
        if (timeA != timeB) {
          return timeB.compareTo(timeA);
        }
        return b.id.compareTo(a.id);
      });

      _programs = newPrograms;
      if (callSnapshot == _callCount) notifyListeners();

      // Phase 2: Fetch missing posters (local or remote) with a small worker pool.
      // Each fetch has its own timeout and cards update as posters arrive, so slow
      // devices don't drop the tail of the row behind one global deadline.
      final queue = newPrograms.where(
        (p) => p.posterArtUri.isNotEmpty && p.posterBytes == null
      ).toList();
      Future<void> worker() async {
        while (queue.isNotEmpty) {
          final p = queue.removeAt(0);
          try {
            final bytes = await _channel
                .getWatchNextPoster(p.posterArtUri)
                .timeout(const Duration(seconds: 15));
            if (bytes != null && bytes.isNotEmpty) {
              p.posterBytes = bytes;
              if (callSnapshot == _callCount) notifyListeners();
            }
          } catch (e) {
            log('Failed to fetch poster for ${p.title}', name: 'WatchNextService', error: e);
          }
        }
      }
      if (queue.isNotEmpty) {
        await Future.wait(List.generate(3, (_) => worker()));
      }
    } catch (e) {
      log('Failed to refresh watch next programs', name: 'WatchNextService', error: e);
    } finally {
      _isFetching = false;
      if (_hasPendingRefresh) {
        _hasPendingRefresh = false;
        refresh();
      }
    }
  }

  WatchNextProgram? _findExisting(int id) {
    for (final p in _programs) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<bool> checkPermission() async {
    return await _channel.checkWatchNextPermission();
  }

  Future<bool> requestPermission() async {
    final bool granted = await _channel.requestWatchNextPermission();
    if (granted) {
      await refresh();
    }
    return granted;
  }

  Future<bool> launch(WatchNextProgram program) async {
    bool launched = false;
    if (program.intentUri.isNotEmpty) {
      try {
        launched = await _channel.launchWatchNextProgram(program.intentUri);
      } catch (e) {
        log('Failed to launch watch next program intent', name: 'WatchNextService', error: e);
      }
    }
    if (!launched && program.packageName.isNotEmpty) {
      try {
        await _channel.launchApp(program.packageName);
        launched = true;
      } catch (e) {
        log('Failed to launch app ${program.packageName}', name: 'WatchNextService', error: e);
      }
    }
    return launched;
  }

  Future<bool> deleteProgram(WatchNextProgram program) async {
    // Optimistically remove from local list for instant UI feedback
    _programs = _programs.where((p) => p.id != program.id).toList();
    notifyListeners();

    bool deleted = false;
    try {
      deleted = await _channel.deleteWatchNextProgram(program.id);
    } catch (e) {
      log('Failed to delete watch next program', name: 'WatchNextService', error: e);
    }
    return deleted;
  }

  @override
  void dispose() {
    if (!_isTest) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _watchNextSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }
}
