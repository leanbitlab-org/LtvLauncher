import 'dart:convert';

import 'package:flauncher/fork/fork_config.dart';

/// Fetches weather from Open-Meteo (no API key) and returns it in the same JSON
/// shape Breezy Weather broadcasts, so WeatherData/WeatherService stay unchanged.
Future<String> fetchOpenMeteoWeatherJson(WeatherLocation loc) async {
  final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
    'latitude': loc.latitude.toString(),
    'longitude': loc.longitude.toString(),
    'current': 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
    'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
    'timezone': 'auto',
    'forecast_days': '7',
  });
  final json = await getJson(uri) as Map<String, dynamic>;
  final current = json['current'] as Map<String, dynamic>;
  final daily = json['daily'] as Map<String, dynamic>;

  final codes = (daily['weather_code'] as List).cast<num?>();
  final maxT = (daily['temperature_2m_max'] as List).cast<num?>();
  final minT = (daily['temperature_2m_min'] as List).cast<num?>();
  final precip = (daily['precipitation_probability_max'] as List).cast<num?>();

  final forecasts = [
    for (var i = 0; i < codes.length; i++)
      {
        'minTemp': minT[i]?.round(),
        'maxTemp': maxT[i]?.round(),
        'conditionCode': wmoToOwm(codes[i]?.toInt()),
        'precipProbability': precip[i]?.round(),
      }
  ];

  final currentWmo = (current['weather_code'] as num?)?.toInt();
  return jsonEncode({
    'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'location': loc.name,
    'currentTemp': (current['temperature_2m'] as num?)?.round(),
    'currentConditionCode': wmoToOwm(currentWmo),
    'currentCondition': wmoDescription(currentWmo),
    'currentHumidity': (current['relative_humidity_2m'] as num?)?.round(),
    'windSpeed': (current['wind_speed_10m'] as num?)?.toDouble(),
    'todayMaxTemp': maxT.isNotEmpty ? maxT[0]?.round() : null,
    'todayMinTemp': minT.isNotEmpty ? minT[0]?.round() : null,
    'forecasts': forecasts,
  });
}

/// WMO weather interpretation codes -> OpenWeatherMap condition codes
/// (what WeatherData's icons and rain/snow/storm warnings expect).
int? wmoToOwm(int? wmo) {
  switch (wmo) {
    case null:
      return null;
    case 0:
      return 800;
    case 1:
      return 801;
    case 2:
      return 802;
    case 3:
      return 804;
    case 45:
    case 48:
      return 741;
    case 51:
    case 53:
    case 55:
    case 61:
      return 500;
    case 56:
    case 57:
    case 66:
    case 67:
      return 511;
    case 63:
      return 501;
    case 65:
      return 502;
    case 71:
      return 600;
    case 73:
      return 601;
    case 75:
      return 602;
    case 77:
      return 611;
    case 80:
      return 520;
    case 81:
      return 521;
    case 82:
      return 522;
    case 85:
      return 620;
    case 86:
      return 622;
    case 95:
      return 211;
    case 96:
    case 99:
      return 202;
    default:
      return 804;
  }
}

String? wmoDescription(int? wmo) {
  if (wmo == null) return null;
  if (wmo == 0) return 'Clear';
  if (wmo <= 2) return 'Partly cloudy';
  if (wmo == 3) return 'Overcast';
  if (wmo == 45 || wmo == 48) return 'Fog';
  if (wmo >= 51 && wmo <= 57) return 'Drizzle';
  if (wmo >= 61 && wmo <= 67) return 'Rain';
  if (wmo >= 71 && wmo <= 77) return 'Snow';
  if (wmo >= 80 && wmo <= 82) return 'Showers';
  if (wmo == 85 || wmo == 86) return 'Snow showers';
  if (wmo >= 95) return 'Thunderstorm';
  return null;
}
