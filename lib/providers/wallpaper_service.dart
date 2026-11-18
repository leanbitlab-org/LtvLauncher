/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:io';
import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/gradients.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class WallpaperService extends ChangeNotifier {
  final FLauncherChannel _fLauncherChannel;
  final SettingsService _settingsService;

  late File _wallpaperFile;
  late File _wallpaperDayFile;
  late File _wallpaperNightFile;
  Timer? _timer;

  ImageProvider? _wallpaper;
  String? _wallpaperPath;
  bool? _lastIsDay;
  int _version = 0;
  int _updateWallpaperCallCount = 0;

  ImageProvider?  get wallpaper     => _wallpaper;
  int             get version       => _version;

  FLauncherGradient get gradient => FLauncherGradients.all.firstWhere(
        (gradient) => gradient.uuid == _settingsService.gradientUuid,
        orElse: () => FLauncherGradients.pitchBlack,
      );

  WallpaperService(this._fLauncherChannel, this._settingsService) :
    _wallpaper = null
  {
    _settingsService.addListener(_onSettingsChanged);
    _init();
  }

  bool _lastTimeBasedEnabled = false;

  void _onSettingsChanged() {
    final enabled = _settingsService.timeBasedWallpaperEnabled;
    if (enabled != _lastTimeBasedEnabled) {
      _lastTimeBasedEnabled = enabled;
      _updateTimerState();
      _updateWallpaper();
    }
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final directory = await getApplicationDocumentsDirectory();
    _wallpaperFile = File("${directory.path}/wallpaper");
    _wallpaperDayFile = File("${directory.path}/wallpaper_day");
    _wallpaperNightFile = File("${directory.path}/wallpaper_night");

    _lastTimeBasedEnabled = _settingsService.timeBasedWallpaperEnabled;
    await _updateWallpaper();
    _updateTimerState();
  }

  void _updateTimerState() {
    final enabled = _settingsService.timeBasedWallpaperEnabled;
    if (enabled && (_timer == null || !_timer!.isActive)) {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) => _onTick());
    } else if (!enabled && _timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  static bool _isDayNow() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 18;
  }

  // The minute tick only touches the file system when day/night flips.
  void _onTick() {
    if (_isDayNow() != _lastIsDay) {
      _updateWallpaper();
    }
  }

  // Decode at screen width instead of the photo's full resolution (a 12MP
  // photo is ~48 MB decoded). Height follows the aspect ratio, which keeps
  // BoxFit.cover sharp for any image not wider than the screen.
  static ImageProvider _sizedImage(File file) {
    final views = PlatformDispatcher.instance.views;
    final width = views.isEmpty ? 0 : views.first.physicalSize.width.round();
    final image = FileImage(file);
    return width > 0 ? ResizeImage(image, width: width) : image;
  }

  Future<void> _updateWallpaper({bool force = false}) async {
    final callId = ++_updateWallpaperCallCount;
    final isDay = _isDayNow();
    final enabled = _settingsService.timeBasedWallpaperEnabled;

    File? newFile;

    if (enabled) {
      if (isDay && await _wallpaperDayFile.exists()) {
        newFile = _wallpaperDayFile;
      } else if (!isDay && await _wallpaperNightFile.exists()) {
        newFile = _wallpaperNightFile;
      } else if (await _wallpaperFile.exists()) {
        newFile = _wallpaperFile; // Fallback
      }
    } else {
      if (await _wallpaperFile.exists()) {
        newFile = _wallpaperFile;
      }
    }

    if (callId == _updateWallpaperCallCount) {
      _lastIsDay = isDay;
      if (_wallpaperPath != newFile?.path || force) {
        _wallpaperPath = newFile?.path;
        _wallpaper = newFile == null ? null : _sizedImage(newFile);
        notifyListeners();
      }
    }
  }

  Future<void> pickWallpaper() async {
    await _pickAndSave(_wallpaperFile);
  }

  Future<void> pickWallpaperDay() async {
    await _pickAndSave(_wallpaperDayFile);
  }

  Future<void> pickWallpaperNight() async {
    await _pickAndSave(_wallpaperNightFile);
  }

  Future<void> _pickAndSave(File targetFile) async {
    if (!await _fLauncherChannel.checkForGetContentAvailability()) {
      throw NoFileExplorerException();
    }

    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Use stream for memory efficiency
      final readStream = pickedFile.openRead();
      final writeStream = targetFile.openWrite();
      await readStream.cast<List<int>>().pipe(writeStream);

      // Evict from cache to ensure UI updates
      await FileImage(targetFile).evict();
      await _sizedImage(targetFile).evict();

      _version++;
      await _updateWallpaper(force: true);
    }
  }

  Future<void> setGradient(FLauncherGradient fLauncherGradient) async {
    if (await _wallpaperFile.exists()) {
      await _wallpaperFile.delete();
    }

    _settingsService.setGradientUuid(fLauncherGradient.uuid);
    // Drop the stale wallpaper image so the gradient shows without a restart.
    await _updateWallpaper(force: true);
  }
}

class NoFileExplorerException implements Exception {}
