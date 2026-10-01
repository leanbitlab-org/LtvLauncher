import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/fork/fork_config.dart';
import 'package:flauncher/models/watch_next_program.dart';
import 'package:flutter/widgets.dart';

const _seerrTvPackage = 'ca.devmesh.seerrtv';
const _maxSeeds = 8;
const _maxJellyfinSeeds = 6;
const _maxResults = 15;

/// Seerr mediaInfo.status values that mean "already have it or already asked for it":
/// 2 pending, 3 processing, 4 partially available, 5 available.
const _excludedStatuses = {2, 3, 4, 5};

class _Seed {
  final String type; // 'movie' | 'tv'
  final int tmdbId;
  final String? title; // null for seeds that came from Seerr requests

  const _Seed(this.type, this.tmdbId, this.title);

  String get key => '$type:$tmdbId';
}

class _Candidate {
  final Map<String, dynamic> result;
  final String type;
  double score = 0;
  _Seed? bestSeed;
  double bestContribution = 0;

  _Candidate(this.result, this.type);
}

/// Fork: a "For You" row of titles NOT yet on the server, recommended by Seerr
/// (TMDB recommendations) from what was recently watched in Jellyfin and recently
/// requested in Seerr. Selecting a card opens the title in SeerrTV to request it.
class SeerrService extends ChangeNotifier with WidgetsBindingObserver {
  final FLauncherChannel _channel;
  SeerrConfig? _seerr;
  JellyfinConfig? _jellyfin;
  Timer? _timer;
  DateTime? _lastRefresh;
  bool _refreshing = false;
  final Map<String, Uint8List> _posterCache = {};

  List<WatchNextProgram> _forYou = const [];

  List<WatchNextProgram> get forYou => _forYou;
  bool get configured => _seerr != null;

  bool get _isTest => Platform.environment.containsKey('FLUTTER_TEST');

  SeerrService(this._channel) {
    if (_isTest) return;
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    final config = await ForkConfig.load();
    _seerr = config.seerr;
    _jellyfin = config.jellyfin;
    if (_seerr == null) return;
    await refresh();
    _timer = Timer.periodic(const Duration(hours: 6), (_) => refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _seerr != null) {
      final last = _lastRefresh;
      if (last == null || DateTime.now().difference(last).inMinutes >= 60) {
        refresh();
      }
    }
  }

  Future<dynamic> _seerrGet(String path, [Map<String, String> query = const {}]) {
    final base = Uri.parse(_seerr!.url);
    final uri = base.replace(path: '${base.path}/api/v1$path', queryParameters: query.isEmpty ? null : query);
    return getJson(uri, headers: {'X-Api-Key': _seerr!.apiKey, 'Accept': 'application/json'});
  }

  Future<dynamic> _jellyfinGet(String path, Map<String, String> query) {
    final base = Uri.parse(_jellyfin!.url);
    final uri = base.replace(path: '${base.path}$path', queryParameters: query);
    return getJson(uri, headers: {'Authorization': 'MediaBrowser Token="${_jellyfin!.apiKey}"'});
  }

  Future<void> refresh() async {
    if (_seerr == null || _refreshing) return;
    _refreshing = true;
    _lastRefresh = DateTime.now();
    try {
      final seeds = <_Seed>[];
      final seen = <String>{};
      void addSeed(_Seed s) {
        if (seeds.length < _maxSeeds && seen.add(s.key)) seeds.add(s);
      }

      for (final s in await _jellyfinSeeds()) {
        addSeed(s);
      }
      for (final s in await _requestSeeds()) {
        addSeed(s);
      }

      final candidates = <String, _Candidate>{};
      final queue = List<_Seed>.of(seeds);
      Future<void> worker() async {
        while (queue.isNotEmpty) {
          final seed = queue.removeAt(0);
          try {
            final json = await _seerrGet('/${seed.type}/${seed.tmdbId}/recommendations', {'page': '1'});
            final results = ((json as Map<String, dynamic>)['results'] as List? ?? const [])
                .cast<Map<String, dynamic>>();
            for (var rank = 0; rank < results.length; rank++) {
              final r = results[rank];
              final type = r['mediaType'] as String? ?? seed.type;
              final id = r['id'];
              if (id is! num || (type != 'movie' && type != 'tv')) continue;
              final key = '$type:${id.toInt()}';
              if (seen.contains(key) || _isExcluded(r)) continue;
              // One point per recommending seed, plus a bonus for ranking highly.
              final contribution = 1 + (results.length - rank) / results.length;
              final c = candidates.putIfAbsent(key, () => _Candidate(r, type));
              c.score += contribution;
              if (contribution > c.bestContribution) {
                c.bestContribution = contribution;
                c.bestSeed = seed;
              }
            }
          } catch (e) {
            developer.log('Recommendations failed for ${seed.key}', name: 'SeerrService', error: e);
          }
        }
      }

      await Future.wait(List.generate(3, (_) => worker()));

      var ranked = candidates.values.toList()..sort((a, b) => b.score.compareTo(a.score));
      if (ranked.isEmpty) ranked = await _trending();

      _forYou = ranked.take(_maxResults).map(_toProgram).toList();
      notifyListeners();
      await _fetchPosters(_forYou);
    } catch (e, stack) {
      developer.log('Seerr refresh failed', name: 'SeerrService', error: e, stackTrace: stack);
    } finally {
      _refreshing = false;
    }
  }

  bool _isExcluded(Map<String, dynamic> r) {
    final status = (r['mediaInfo'] as Map<String, dynamic>?)?['status'];
    return status is num && _excludedStatuses.contains(status.toInt());
  }

  /// Recently played Jellyfin movies and series (episodes collapse to their series).
  Future<List<_Seed>> _jellyfinSeeds() async {
    final jf = _jellyfin;
    if (jf == null) return const [];
    try {
      final played = await _jellyfinGet('/Items', {
        'userId': jf.userId,
        'filters': 'IsPlayed',
        'sortBy': 'DatePlayed',
        'sortOrder': 'Descending',
        'includeItemTypes': 'Movie,Episode',
        'recursive': 'true',
        'limit': '60',
        'fields': 'ProviderIds,SeriesId',
      }) as Map<String, dynamic>;
      final items = (played['Items'] as List).cast<Map<String, dynamic>>();

      final seeds = <_Seed>[];
      final seriesOrder = <String>[];
      final seriesNames = <String, String>{};
      final order = <Object>[]; // _Seed for movies, series id String for episodes, in play order
      for (final item in items) {
        if (item['Type'] == 'Movie') {
          final tmdb = int.tryParse('${(item['ProviderIds'] as Map?)?['Tmdb'] ?? ''}');
          if (tmdb != null) order.add(_Seed('movie', tmdb, item['Name'] as String?));
        } else if (item['SeriesId'] is String) {
          final sid = item['SeriesId'] as String;
          if (!seriesNames.containsKey(sid)) {
            seriesNames[sid] = item['SeriesName'] as String? ?? '';
            seriesOrder.add(sid);
            order.add(sid);
          }
        }
        if (order.length >= _maxJellyfinSeeds) break;
      }

      final seriesTmdb = <String, int>{};
      if (seriesOrder.isNotEmpty) {
        final series = await _jellyfinGet('/Items', {
          'userId': jf.userId,
          'ids': seriesOrder.join(','),
          'fields': 'ProviderIds',
        }) as Map<String, dynamic>;
        for (final s in (series['Items'] as List).cast<Map<String, dynamic>>()) {
          final tmdb = int.tryParse('${(s['ProviderIds'] as Map?)?['Tmdb'] ?? ''}');
          if (tmdb != null) seriesTmdb[s['Id'] as String] = tmdb;
        }
      }

      for (final o in order) {
        if (o is _Seed) {
          seeds.add(o);
        } else if (seriesTmdb[o] != null) {
          seeds.add(_Seed('tv', seriesTmdb[o]!, seriesNames[o]));
        }
      }
      return seeds;
    } catch (e) {
      // Off the home network Jellyfin is unreachable; request seeds still work.
      developer.log('Jellyfin seeds unavailable', name: 'SeerrService', error: e);
      return const [];
    }
  }

  Future<List<_Seed>> _requestSeeds() async {
    try {
      final json = await _seerrGet('/request', {
        'take': '20',
        'sort': 'added',
        'sortDirection': 'desc',
        'filter': 'all',
      }) as Map<String, dynamic>;
      final seeds = <_Seed>[];
      for (final r in (json['results'] as List? ?? const []).cast<Map<String, dynamic>>()) {
        final media = r['media'] as Map<String, dynamic>?;
        final type = media?['mediaType'] as String?;
        final tmdb = media?['tmdbId'];
        if ((type == 'movie' || type == 'tv') && tmdb is num) seeds.add(_Seed(type!, tmdb.toInt(), null));
      }
      return seeds;
    } catch (e) {
      developer.log('Request seeds unavailable', name: 'SeerrService', error: e);
      return const [];
    }
  }

  Future<List<_Candidate>> _trending() async {
    try {
      final json = await _seerrGet('/discover/trending', {'page': '1'}) as Map<String, dynamic>;
      return (json['results'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .where((r) => (r['mediaType'] == 'movie' || r['mediaType'] == 'tv') && !_isExcluded(r))
          .map((r) => _Candidate(r, r['mediaType'] as String))
          .toList();
    } catch (e) {
      developer.log('Trending unavailable', name: 'SeerrService', error: e);
      return const [];
    }
  }

  WatchNextProgram _toProgram(_Candidate c) {
    final r = c.result;
    final id = (r['id'] as num).toInt();
    final isMovie = c.type == 'movie';
    final title = (isMovie ? r['title'] : r['name']) as String? ?? '';
    final date = (isMovie ? r['releaseDate'] : r['firstAirDate']) as String? ?? '';
    final seed = c.bestSeed;
    final reason = seed == null
        ? 'Trending'
        : (seed.title != null && seed.title!.isNotEmpty ? 'Because you watched ${seed.title}' : 'Based on your requests');
    final description = [
      if (date.length >= 4) date.substring(0, 4),
      isMovie ? 'Movie' : 'Series',
      reason,
    ].join(' · ');

    final backdrop = r['backdropPath'] as String?;
    final poster = r['posterPath'] as String?;
    final art = backdrop != null && backdrop.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w780$backdrop'
        : (poster != null && poster.isNotEmpty ? 'https://image.tmdb.org/t/p/w500$poster' : '');

    return WatchNextProgram(
      id: 'seerr-${c.type}-$id'.hashCode,
      packageName: _seerrTvPackage,
      title: title,
      description: description,
      watchNextType: 0,
      lastEngagementTime: 0,
      playbackPosition: 0,
      duration: 0,
      intentUri: 'seerrtv://details/${c.type}/$id',
      posterArtUri: art,
      posterBytes: _posterCache[art],
    );
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
          developer.log('Poster fetch failed for ${p.title}', name: 'SeerrService', error: e);
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
