/*
 * LTvLauncher
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

import 'package:flutter/widgets.dart';

/// Strings of the LTL features: Russian with an English fallback.
///
/// They are kept apart from the generated gen-l10n classes on purpose:
/// a new ARB key means regenerating all 16 locale files, while these
/// features only need Russian and English.
class LtlStrings {
  final bool _ru;

  const LtlStrings._(this._ru);

  static const LtlStrings russian = LtlStrings._(true);
  static const LtlStrings english = LtlStrings._(false);

  static LtlStrings of(BuildContext context) =>
      Localizations.maybeLocaleOf(context)?.languageCode == 'ru' ? russian : english;

  String _t(String ru, String en) => _ru ? ru : en;

  // Common
  String get enabled => _t('Включено', 'Enabled');
  String get disabled => _t('Выключено', 'Disabled');
  String get granted => _t('Выдано', 'Granted');
  String get notGranted => _t('Не выдано', 'Not granted');
  String get loading => _t('Загрузка…', 'Loading…');
  String get close => _t('Закрыть', 'Close');
  String get notAvailable => _t('Недоступно', 'Not available');

  // Settings menu
  String get supportAndDonate => _t('Поддержка и пожертвования', 'Support & Donate');

  // Development
  String get developer => _t('Разработка', 'Development');
  String get adbStatus => _t('Статус ADB', 'ADB status');
  String get adbDebugging => _t('Отладка по ADB', 'ADB debugging');
  String get adbDebuggingHint => _t('Включение и выключение отладки (USB и сеть)', 'Turn USB and network debugging on or off');
  String get wifiDebugging => _t('Отладка по Wi-Fi', 'Wireless debugging');
  String get wifiDebuggingHint =>
      _t('Android 11+: подключение по сети после сопряжения', 'Android 11+: connect over the network after pairing');
  String get connectAddress => _t('Адрес в сети', 'Network address');
  String get wirelessPortHint => _t('порт — в разделе «Отладка по Wi-Fi»', 'port is shown in Wireless debugging');
  String get networkAdbOff => _t('сетевой ADB выключен', 'network ADB is off');
  String get developerOptions => _t('Режим разработчика', 'Developer options');
  String get permission => _t('Системное разрешение', 'System permission');
  String get animationScale => _t('Скорость анимаций системы', 'System animation speed');
  String get animationScaleHint => _t('0.5x или «Выкл.» делают ТВ отзывчивее', '0.5x or Off makes the TV feel snappier');
  String get animationOff => _t('Выкл.', 'Off');
  String get openDeveloperOptions => _t('Открыть параметры разработчика', 'Open developer options');
  String get controlPermission => _t('Разрешение на управление', 'Control permission');
  String get grantExplanation => _t(
      'Android разрешает менять настройки отладки только приложениям с разрешением WRITE_SECURE_SETTINGS. '
          'Выдайте его один раз с компьютера, подключившись к ТВ по ADB:',
      'Android only lets apps holding WRITE_SECURE_SETTINGS change debugging settings. '
          'Grant it once from a computer connected to the TV over ADB:');
  String get grantAfterHint => _t('После выполнения команды вернитесь сюда — статус обновится автоматически.',
      'After running the command come back here, the status refreshes automatically.');
  String get refreshStatus => _t('Обновить статус', 'Refresh status');
  String get changeFailed => _t('Не удалось изменить настройку', 'Could not change the setting');
  String get deviceInfo => _t('Об устройстве', 'Device');
  String get model => _t('Модель', 'Model');
  String get build => _t('Сборка', 'Build');
  String get ipAddress => _t('IP-адрес', 'IP address');
  String get detected => _t('Обнаружена', 'Detected');
  String get notDetected => _t('Не обнаружена', 'Not detected');
}
