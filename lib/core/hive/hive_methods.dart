import 'dart:io';

import 'package:flutter/material.dart';
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
    final String currentVersion = "${packageInfo.version}+${packageInfo.buildNumber}";
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
    return _box.get('token');
  }

  static void updateToken(String token) {
    _box.put('token', token);
  }

  static void deleteToken() {
    _box.delete('token');
  }

  static bool isFirstTime() {
    return _box.get('isFirstTime', defaultValue: true);
  }

  static void updateFirstTime() {
    _box.put('isFirstTime', false);
  }
}
