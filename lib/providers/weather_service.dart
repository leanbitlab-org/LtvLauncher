import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/models/weather_data.dart';
import 'package:flutter/widgets.dart';

class WeatherService extends ChangeNotifier with WidgetsBindingObserver {
  final FLauncherChannel _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _refreshTimer;
  DateTime? _lastResumeCheck;
  String? _lastJson;

  WeatherData? _weatherData;
  bool _isBreezyInstalled = false;
  bool _initialized = false;

  bool get _isTest => Platform.environment.containsKey('FLUTTER_TEST');

  WeatherService(this._channel) {
    if (!_isTest) {
      WidgetsBinding.instance.addObserver(this);
    }
    _init();
  }

  WeatherData? get weatherData => _weatherData;
  bool get isBreezyInstalled => _isBreezyInstalled;
  bool get initialized => _initialized;
  bool get hasWeather => _weatherData != null;

  Future<void> _init() async {
    try {
      await _fetchLatest();

      _subscription = _channel.addWeatherChangedListener((event) {
        if (event is String && event.isNotEmpty) {
          _processWeatherJson(event);
        }
      });
      _startPeriodicTimer();
    } catch (e, stack) {
      developer.log("Error initializing WeatherService", error: e, stackTrace: stack);
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  void _startPeriodicTimer() {
    _refreshTimer?.cancel();
    // 15-minute fallback timer in case a broadcast was missed while paused
    _refreshTimer = Timer.periodic(const Duration(minutes: 15), (_) => _fetchLatest());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _refreshTimer?.cancel();
      _refreshTimer = null;
    } else if (state == AppLifecycleState.resumed) {
      _checkWeatherOnResume();
      _startPeriodicTimer();
    }
  }

  Future<void> _checkWeatherOnResume() async {
    final now = DateTime.now();
    if (_lastResumeCheck != null && now.difference(_lastResumeCheck!).inSeconds < 60) {
      return;
    }
    _lastResumeCheck = now;
    await _fetchLatest();
  }

  Future<void> _fetchLatest() async {
    try {
      _isBreezyInstalled = await _channel.isBreezyWeatherInstalled();
      final latestJson = await _channel.getLatestWeatherData();
      if (latestJson != null && latestJson.isNotEmpty) {
        _processWeatherJson(latestJson);
      }
    } catch (e, stack) {
      developer.log("Failed to fetch latest weather data", error: e, stackTrace: stack);
    }
  }

  void _processWeatherJson(String jsonString) {
    if (jsonString == _lastJson && _weatherData != null) {
      return;
    }
    try {
      _weatherData = WeatherData.fromJsonString(jsonString);
      _lastJson = jsonString;
      notifyListeners();
    } catch (e, stack) {
      developer.log("Failed to parse weather JSON", error: e, stackTrace: stack);
    }
  }

  Future<bool> openBreezyWeather() async {
    try {
      return await _channel.openBreezyWeather();
    } catch (e) {
      return false;
    }
  }

  Future<void> refresh() async {
    await _fetchLatest();
    notifyListeners();
  }

  @override
  void dispose() {
    if (!_isTest) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _refreshTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
