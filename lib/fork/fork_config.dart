import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Fork-only configuration, read from `<external files dir>/fork_config.json`
/// (e.g. /sdcard/Android/data/com.leanbitlab.ltvL.posters/files/fork_config.json).
///
/// Kept out of SharedPreferences and backups on purpose: it holds the Jellyfin
/// API key, and is pushed with adb rather than typed on a TV remote.
///
/// {
///   "weather":  { "name": "Auckland", "latitude": -36.8485, "longitude": 174.7633 },
///   "jellyfin": { "url": "http://192.168.0.243:8096", "apiKey": "...", "userId": "..." }
/// }
class ForkConfig {
  final WeatherLocation weather;
  final JellyfinConfig? jellyfin;

  const ForkConfig({required this.weather, this.jellyfin});

  static const _defaultWeather = WeatherLocation(name: 'Auckland', latitude: -36.8485, longitude: 174.7633);

  static Future<ForkConfig>? _cached;

  static Future<ForkConfig> load() => _cached ??= _load();

  static Future<ForkConfig> _load() async {
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) return const ForkConfig(weather: _defaultWeather);
      final file = File('${dir.path}/fork_config.json');
      if (!await file.exists()) return const ForkConfig(weather: _defaultWeather);
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return ForkConfig(
        weather: WeatherLocation.fromJson(json['weather'] as Map<String, dynamic>?) ?? _defaultWeather,
        jellyfin: JellyfinConfig.fromJson(json['jellyfin'] as Map<String, dynamic>?),
      );
    } catch (e, stack) {
      developer.log('Failed to read fork_config.json', name: 'ForkConfig', error: e, stackTrace: stack);
      return const ForkConfig(weather: _defaultWeather);
    }
  }
}

class WeatherLocation {
  final String name;
  final double latitude;
  final double longitude;

  const WeatherLocation({required this.name, required this.latitude, required this.longitude});

  static WeatherLocation? fromJson(Map<String, dynamic>? json) {
    if (json == null || json['latitude'] is! num || json['longitude'] is! num) return null;
    return WeatherLocation(
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class JellyfinConfig {
  final String url;
  final String apiKey;
  final String userId;

  const JellyfinConfig({required this.url, required this.apiKey, required this.userId});

  static JellyfinConfig? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final url = (json['url'] as String? ?? '').replaceAll(RegExp(r'/+$'), '');
    final apiKey = json['apiKey'] as String? ?? '';
    final userId = json['userId'] as String? ?? '';
    if (url.isEmpty || apiKey.isEmpty || userId.isEmpty) return null;
    return JellyfinConfig(url: url, apiKey: apiKey, userId: userId);
  }
}

/// Minimal JSON GET over dart:io (the project has no http package).
Future<dynamic> getJson(Uri uri, {Map<String, String> headers = const {}, Duration timeout = const Duration(seconds: 10)}) async {
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final req = await client.getUrl(uri).timeout(timeout);
    headers.forEach(req.headers.set);
    final res = await req.close().timeout(timeout);
    final body = await res.transform(utf8.decoder).join().timeout(timeout);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw HttpException('HTTP ${res.statusCode}', uri: uri);
    }
    return jsonDecode(body);
  } finally {
    client.close(force: true);
  }
}
