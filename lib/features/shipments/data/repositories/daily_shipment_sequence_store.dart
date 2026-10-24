import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/shipment.dart';

abstract interface class DailyShipmentSequencePreferences {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);
}

abstract interface class ShipmentSequenceStore {
  Future<Map<String, int>> assignNumbers(
    Iterable<Shipment> shipments, {
    DateTime? date,
  });
}

class DailyShipmentSequenceStore implements ShipmentSequenceStore {
  DailyShipmentSequenceStore({DailyShipmentSequencePreferences? preferences})
      : _preferences =
            preferences ?? _SharedPreferencesDailySequencePreferences();

  final DailyShipmentSequencePreferences _preferences;

  /// Assignments are queued globally (not per instance) so concurrent callers
  /// never read-and-extend the same day's sequence and produce duplicate
  /// numbers.
  static Future<void> _pendingAssignment = Future.value();

  @override
  Future<Map<String, int>> assignNumbers(
    Iterable<Shipment> shipments, {
    DateTime? date,
  }) {
    final completer = Completer<Map<String, int>>();
    final shipmentBatch = List<Shipment>.of(shipments);
    _pendingAssignment = _pendingAssignment.then((_) async {
      try {
        completer.complete(
          await _assignNumbers(shipmentBatch, date: date),
        );
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  Future<Map<String, int>> _assignNumbers(
    List<Shipment> shipments, {
    DateTime? date,
  }) async {
    final key = _keyForDate(date ?? DateTime.now());
    final sequences = await _read(key);
    final unnumbered = shipments
        .where((shipment) => !sequences.containsKey(shipment.id))
        .toList()
      ..sort(compareByShipmentNumber);

    var nextNumber = sequences.values.fold<int>(
          0,
          (highest, number) => number > highest ? number : highest,
        ) +
        1;
    for (final shipment in unnumbered) {
      sequences[shipment.id] = nextNumber++;
    }

    if (unnumbered.isNotEmpty) {
      await _preferences.setString(key, jsonEncode(sequences));
    }
    return Map.unmodifiable(sequences);
  }

  static int compareByShipmentNumber(Shipment left, Shipment right) {
    final leftNumber = left.orderId ?? left.id;
    final rightNumber = right.orderId ?? right.id;
    final leftParts = RegExp(r'\d+|\D+')
        .allMatches(leftNumber.toLowerCase())
        .map((match) => match.group(0)!)
        .toList();
    final rightParts = RegExp(r'\d+|\D+')
        .allMatches(rightNumber.toLowerCase())
        .map((match) => match.group(0)!)
        .toList();

    for (var index = 0;
        index < leftParts.length && index < rightParts.length;
        index++) {
      final leftPart = leftParts[index];
      final rightPart = rightParts[index];
      final leftValue = int.tryParse(leftPart);
      final rightValue = int.tryParse(rightPart);
      final comparison = leftValue != null && rightValue != null
          ? leftValue.compareTo(rightValue)
          : leftPart.compareTo(rightPart);
      if (comparison != 0) return comparison;
    }
    return leftParts.length.compareTo(rightParts.length);
  }

  Future<Map<String, int>> _read(String key) async {
    final raw = await _preferences.getString(key);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return {
        for (final entry in decoded.entries)
          if (entry.key is String && entry.value is int)
            entry.key as String: entry.value as int,
      };
    } on FormatException {
      return {};
    }
  }

  String _keyForDate(DateTime date) => 'daily_shipment_sequence_${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class _SharedPreferencesDailySequencePreferences
    implements DailyShipmentSequencePreferences {
  /// Constructed lazily: building [SharedPreferencesAsync] requires a
  /// registered platform instance, which only exists on real devices.
  SharedPreferencesAsync? _preferences;

  SharedPreferencesAsync get _asyncPreferences =>
      _preferences ??= SharedPreferencesAsync();

  @override
  Future<String?> getString(key) => _asyncPreferences.getString(key);

  @override
  Future<void> setString(key, value) => _asyncPreferences.setString(key, value);
}
