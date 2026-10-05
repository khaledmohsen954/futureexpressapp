import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores non-sensitive local preferences and report metadata on this device.
class LocalPreviewRepository {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  static const _key = 'future_express_preview_v1';

  Future<Map<String, dynamic>> read() async {
    final raw = await _preferences.getString(_key);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : {};
    } on FormatException {
      return {};
    }
  }

  Future<void> write(Map<String, dynamic> value) async {
    await _preferences.setString(_key, jsonEncode(value));
  }
}
