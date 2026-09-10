import 'package:flauncher/models/weather_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeatherData Model', () {
    test('parses basic weather json correctly', () {
      const jsonStr = '''
      {
        "timestamp": 1690000000,
        "location": "New York",
        "currentTemp": 22,
        "currentConditionCode": 800,
        "currentCondition": "Clear",
        "currentHumidity": 55,
        "windSpeed": 3.5,
        "todayMaxTemp": 26,
        "todayMinTemp": 18,
        "forecasts": []
      }
      ''';

      final weather = WeatherData.fromJsonString(jsonStr);

      expect(weather.location, "New York");
      expect(weather.currentTemp, 22);
      expect(weather.currentConditionCode, 800);
      expect(weather.currentCondition, "Clear");
      expect(weather.currentHumidity, 55);
      expect(weather.windSpeed, 3.5);
      expect(weather.todayMaxTemp, 26);
      expect(weather.todayMinTemp, 18);
      expect(weather.hasWarning, false);
      expect(weather.warningType, WeatherWarningType.none);
      expect(weather.formatTemperature(useFahrenheit: false), "22°C");
      expect(weather.formatTemperature(useFahrenheit: true), "72°F");
      expect(weather.getConditionIcon(), Icons.wb_sunny_outlined);
    });

    test('converts Kelvin temperatures from Breezy Weather broadcast to Celsius', () {
      const jsonStr = '''
      {
        "location": "Breezy Location",
        "currentTemp": 300,
        "todayMinTemp": 293,
        "todayMaxTemp": 303,
        "forecasts": [
          {
            "conditionCode": 800,
            "minTemp": 294,
            "maxTemp": 304
          }
        ]
      }
      ''';

      final weather = WeatherData.fromJsonString(jsonStr);

      // 300 K - 273.15 = 26.85 -> 27°C
      expect(weather.currentTemp, 27);
      expect(weather.todayMinTemp, 20); // 293 - 273.15 = 19.85 -> 20°C
      expect(weather.todayMaxTemp, 30); // 303 - 273.15 = 29.85 -> 30°C
      expect(weather.forecasts.first.minTemp, 21); // 294 - 273.15 = 20.85 -> 21°C
      expect(weather.forecasts.first.maxTemp, 31); // 304 - 273.15 = 30.85 -> 31°C
      expect(weather.formatTemperature(useFahrenheit: false), "27°C");
      expect(weather.formatTemperature(useFahrenheit: true), "81°F");
    });

    test('detects rain warning today in forecast', () {
      const jsonStr = '''
      {
        "currentTemp": 19,
        "currentConditionCode": 801,
        "currentCondition": "Partly Cloudy",
        "forecasts": [
          {
            "conditionCode": 500,
            "precipProbability": 80,
            "minTemp": 15,
            "maxTemp": 21
          }
        ]
      }
      ''';

      final weather = WeatherData.fromJsonString(jsonStr);

      expect(weather.hasWarning, true);
      expect(weather.warningType, WeatherWarningType.rain);
      expect(weather.warningConditionCode, 500);
      expect(weather.warningPrecipProbability, 80);
      expect(weather.warningText, "80% Rain today");
      expect(weather.getConditionIcon(isWarning: true), Icons.grain_outlined);
    });

    test('detects snow warning tomorrow in forecast', () {
      const jsonStr = '''
      {
        "currentTemp": -2,
        "currentConditionCode": 804,
        "currentCondition": "Overcast",
        "forecasts": [
          {
            "conditionCode": 804,
            "precipProbability": 0,
            "minTemp": -4,
            "maxTemp": 0
          },
          {
            "conditionCode": 601,
            "precipProbability": 60,
            "minTemp": -5,
            "maxTemp": -1
          }
        ]
      }
      ''';

      final weather = WeatherData.fromJsonString(jsonStr);

      expect(weather.hasWarning, true);
      expect(weather.warningType, WeatherWarningType.snow);
      expect(weather.warningConditionCode, 601);
      expect(weather.warningText, "60% Snow tomorrow");
      expect(weather.getConditionIcon(isWarning: true), Icons.ac_unit_outlined);
    });

    test('detects thunderstorm warning in forecast', () {
      const jsonStr = '''
      {
        "currentTemp": 25,
        "currentConditionCode": 800,
        "forecasts": [
          {
            "conditionCode": 211,
            "precipProbability": 90,
            "minTemp": 20,
            "maxTemp": 28
          }
        ]
      }
      ''';

      final weather = WeatherData.fromJsonString(jsonStr);

      expect(weather.hasWarning, true);
      expect(weather.warningType, WeatherWarningType.storm);
      expect(weather.warningText, "90% Storm today");
      expect(weather.getConditionIcon(isWarning: true), Icons.flash_on_outlined);
    });
  });
}
