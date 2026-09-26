import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/fork/fork_config.dart';
import 'package:flauncher/models/watch_next_program.dart';
import 'package:flutter/widgets.dart';

const _jellyfinPackage = 'org.jellyfin.androidtv';

/// Fork: "Next Up" and "Recently Added" from a Jellyfin server, exposed as
/// WatchNextProgram objects so the Continue Watching card can render them.
/// Selecting a card opens the item's page in the Jellyfin Android TV app.
class JellyfinService extends ChangeNotifier with WidgetsBindingObserver {
  final FLauncherChannel _channel;
  JellyfinConfig? _config;
  Timer? _timer;
  DateTime? _lastRefresh;
  bool _refreshing = false;
  final Map<String, Uint8List> _posterCache = {};

  List<WatchNextProgram> _nextUp = const [];
  List<WatchNextProgram> _recentlyAdded = const [];

  List<WatchNextProgram> get nextUp => _nextUp;
  List<WatchNextProgram> get recentlyAdded => _recentlyAdded;
  bool get configured => _config != null;

  bool get _isTest => Platform.environment.containsKey('FLUTTER_TEST');

  JellyfinService(this._channel) {
    if (_isTest) return;
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    _config = (await ForkConfig.load()).jellyfin;
    if (_config == null) return;
    await refresh();
    _timer = Timer.periodic(const Duration(minutes: 10), (_) => refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _config != null) {
      final last = _lastRefresh;
      if (last == null || DateTime.now().difference(last).inSeconds >= 60) {
        refresh();
      }
    }
  }

  Map<String, String> get _headers => {'Authorization': 'MediaBrowser Token="${_config!.apiKey}"'};

  Uri _uri(String path, Map<String, String> query) {
    final base = Uri.parse(_config!.url);
    return base.replace(path: '${base.path}$path', queryParameters: query);
  }

  Future<void> refresh() async {
    final config = _config;
    if (config == null || _refreshing) return;
    _refreshing = true;
    _lastRefresh = DateTime.now();
    try {
      const common = {
        'limit': '15',
        'fields': 'Overview',
        'enableUserData': 'true',
        'enableImageTypes': 'Primary,Backdrop,Thumb',
      };
      final results = await Future.wait([
        getJson(_uri('/Shows/NextUp', {...common, 'userId': config.userId}), headers: _headers),
        getJson(_uri('/Items/Latest', {...common, 'userId': config.userId}), headers: _headers),
      ]);
      final nextUpItems = ((results[0] as Map<String, dynamic>)['Items'] as List).cast<Map<String, dynamic>>();
      final latestItems = (results[1] as List).cast<Map<String, dynamic>>();

      _nextUp = nextUpItems.map((i) => _toProgram(i, 'next')).toList();
      _recentlyAdded = latestItems.map((i) => _toProgram(i, 'latest')).toList();
      notifyListeners();
      await _fetchPosters([..._nextUp, ..._recentlyAdded]);
    } catch (e, stack) {
      developer.log('Jellyfin refresh failed', name: 'JellyfinService', error: e, stackTrace: stack);
    } finally {
      _refreshing = false;
    }
  }

  WatchNextProgram _toProgram(Map<String, dynamic> item, String row) {
    final id = item['Id'] as String;
    final type = item['Type'] as String? ?? '';
    final userData = item['UserData'] as Map<String, dynamic>? ?? const {};
    final ticksToMs = (dynamic t) => t is num ? t ~/ 10000 : 0;

    String title;
    String description;
    if (type == 'Episode') {
      title = item['SeriesName'] as String? ?? item['Name'] as String? ?? '';
      final s = item['ParentIndexNumber'];
      final e = item['IndexNumber'];
      final code = (s != null && e != null) ? 'S${s}E$e · ' : '';
      description = '$code${item['Name'] ?? ''}';
    } else if (type == 'Series') {
      title = item['Name'] as String? ?? '';
      final unplayed = userData['UnplayedItemCount'];
      description = (unplayed is num && unplayed > 0)
          ? '$unplayed unwatched episode${unplayed == 1 ? '' : 's'}'
          : (item['Overview'] as String? ?? '');
    } else {
      title = item['Name'] as String? ?? '';
      final year = item['ProductionYear'];
      description = [if (year != null) '$year', type == 'Movie' ? 'Movie' : type].join(' · ');
    }

    final posterUri = _imageUri(item);
    return WatchNextProgram(
      id: 'jf-$row-$id'.hashCode,
      packageName: _jellyfinPackage,
      title: title,
      description: description,
      watchNextType: 0,
      lastEngagementTime: 0,
      playbackPosition: ticksToMs(userData['PlaybackPositionTicks']),
      duration: ticksToMs(item['RunTimeTicks']),
      intentUri: 'intent:#Intent;component=$_jellyfinPackage/.ui.startup.StartupActivity;S.ItemId=$id;end',
      posterArtUri: posterUri,
      posterBytes: _posterCache[posterUri],
    );
  }

  /// Prefer wide artwork for the 16:9 card: series thumb/backdrop for episodes,
  /// the item's own thumb/backdrop otherwise, falling back to the primary image.
  String _imageUri(Map<String, dynamic> item) {
    String img(String itemId, String type, String? tag) =>
        _uri('/Items/$itemId/Images/$type', {'maxWidth': '640', if (tag != null) 'tag': tag}).toString();

    final tags = item['ImageTags'] as Map<String, dynamic>? ?? const {};
    final backdrops = (item['BackdropImageTags'] as List?)?.cast<String>() ?? const [];
    final parentBackdrops = (item['ParentBackdropImageTags'] as List?)?.cast<String>() ?? const [];

    if (item['Type'] == 'Episode') {
      if (item['ParentThumbItemId'] != null) {
        return img(item['ParentThumbItemId'], 'Thumb', item['ParentThumbImageTag'] as String?);
      }
      if (item['ParentBackdropItemId'] != null && parentBackdrops.isNotEmpty) {
        return img(item['ParentBackdropItemId'], 'Backdrop', parentBackdrops.first);
      }
    }
    final id = item['Id'] as String;
    if (tags['Thumb'] != null) return img(id, 'Thumb', tags['Thumb'] as String);
    if (backdrops.isNotEmpty) return img(id, 'Backdrop', backdrops.first);
    if (tags['Primary'] != null) return img(id, 'Primary', tags['Primary'] as String);
    return '';
  }

  Future<void> _fetchPosters(List<WatchNextProgram> programs) async {
    final queue = programs.where((p) => p.posterArtUri.isNotEmpty && p.posterBytes == null).toList();
    Future<void> worker() async {
      while (queue.isNotEmpty) {
        final p = queue.removeAt(0);
        try {
          final bytes = await _channel.getWatchNextPoster(p.posterArtUri).timeout(const Duration(seconds: 15));
          if (bytes != null && bytes.isNotEmpty) {
            p.posterBytes = bytes;
            _posterCache[p.posterArtUri] = bytes;
            notifyListeners();
          }
        } catch (e) {
          developer.log('Poster fetch failed for ${p.title}', name: 'JellyfinService', error: e);
        }
      }
    }

    await Future.wait(List.generate(3, (_) => worker()));
  }

  @override
  void dispose() {
    if (!_isTest) WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}
