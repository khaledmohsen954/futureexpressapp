import 'dart:io';

import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/theme/theme_enum.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HiveMethods {
  static final _box = Hive.box('app');

  static Future<void> clearCache() async {
    // Keep essential data like language and theme if needed,
    // or clear everything as requested.
    // For "clear cash of the app", we usually mean everything.
    await _box.clear();
  }

  static Future<void> checkVersionAndClearCache() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion =
        "${packageInfo.version}+${packageInfo.buildNumber}";
    final String? savedVersion = _box.get('app_version');

    if (savedVersion != null && savedVersion != currentVersion) {
      await clearCache();
    }

    await _box.put('app_version', currentVersion);
  }

  static String getLang() {
    // Return saved language if exists
    if (_box.containsKey('lang')) {
      return _box.get('lang');
    }

    // Auto-detect device language
    try {
      // Handle both en_US and en-US formats
      final String deviceLocale = Platform.localeName;
      final String langCode = deviceLocale.split(RegExp('[-_]'))[0];

      if (['ar', 'en', 'ur'].contains(langCode)) {
        return langCode;
      }
    } catch (_) {}

    // Default to English
    return 'en';
  }

  static void updateLang(Locale locale) {
    _box.put('lang', locale.languageCode);
  }

  static String? getToken() {
    if (!Hive.isBoxOpen('app')) return null;
    return _box.get('api_token') as String? ?? _box.get('token') as String?;
  }

  static Future<void> updateToken(String token) {
    return _box.put('api_token', token);
  }

  static Future<void> deleteToken() async {
    await _box.delete('api_token');
    await _box.delete('token');
  }

  static Map<String, dynamic>? getUserData() {
    if (!Hive.isBoxOpen('app')) return null;
    final data = _box.get('user_data');
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  static Future<void> updateUserData(Map<String, dynamic> userData) {
    return _box.put('user_data', userData);
  }

  static Future<void> deleteUserData() {
    return _box.delete('user_data');
  }

  static bool? getShiftStatus() {
    if (!Hive.isBoxOpen('app') || !_box.containsKey('shift_status')) {
      return null;
    }
    final value = _box.get('shift_status');
    if (value is bool) return value;
    if (value is num) return value != 0;
    return null;
  }

  static Future<void> updateShiftStatus(bool onDuty) {
    return _box.put('shift_status', onDuty ? 1 : 0);
  }

  static bool isFirstTime() {
    return _box.get('isFirstTime', defaultValue: true);
  }

  static void updateFirstTime() {
    _box.put('isFirstTime', false);
  }

  static ThemeEnum getTheme() {
    if (_box.containsKey('theme')) {
      return _box.get('theme');
    }
    // Default to system theme
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark ? ThemeEnum.dark : ThemeEnum.light;
  }

  static void updateThem(ThemeEnum theme) {
    _box.put('theme', theme);
  }
}
