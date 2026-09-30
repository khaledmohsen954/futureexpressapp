import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

enum LocationPermissionStatus { granted, serviceDisabled, denied, deniedForever }

class MapService {
  // ============================================================
  // Cached current position
  // ============================================================

  static Position? _currentPosition;

  /// آخر Location تم الحصول عليه بنجاح.
  ///
  /// أي Service أو Helper محتاج الموقع يقدر يستخدمها
  /// بدون ما يعمل request جديد للـ GPS.
  static Position? get currentPosition => _currentPosition;

  /// هل عندنا Location محفوظة؟
  static bool get hasCurrentPosition => _currentPosition != null;

  // ============================================================
  // Permission
  // ============================================================

  /// طلب صلاحية الموقع.
  ///
  /// مهم:
  /// - لا يفتح App Settings تلقائيًا.
  /// - لا يفتح Location Settings تلقائيًا.
  /// - يرجع حالة واضحة للـ UI.
  static Future<LocationPermissionStatus> requestLocationPermission() async {
    final currentStatus = await getLocationPermissionStatus();
    if (currentStatus != LocationPermissionStatus.denied) {
      return currentStatus;
    }

    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      return LocationPermissionStatus.granted;
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }
    return LocationPermissionStatus.denied;
  }

  /// Returns the current location state without showing a permission prompt.
  static Future<LocationPermissionStatus> getLocationPermissionStatus() async {
    // Check if Location/GPS service is enabled.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    final permission = await Geolocator.checkPermission();

    // Permission granted.
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      return LocationPermissionStatus.granted;
    }

    // User denied permission.
    if (permission == LocationPermission.denied) {
      return LocationPermissionStatus.denied;
    }

    // Permission permanently denied.
    // DO NOT open settings automatically.
    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }

    return LocationPermissionStatus.denied;
  }

  // ============================================================
  // Current Position
  // ============================================================

  /// الحصول على الموقع الحالي.
  ///
  /// لو الموقع اتجاب قبل كده:
  /// يرجع الـ cached Position فورًا بدون انتظار GPS.
  ///
  /// لو مفيش Position محفوظة:
  /// يعمل request مرة واحدة ويحفظ النتيجة.
  static Future<Position?> getCurrentPosition({bool forceRefresh = false}) async {
    // لو عندنا Location بالفعل ومش طالب Refresh
    // رجعها فورًا.
    if (_currentPosition != null && !forceRefresh) {
      return _currentPosition;
    }

    // Check permission.
    final status = await requestLocationPermission();

    if (status != LocationPermissionStatus.granted) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // Cache position.
      _currentPosition = position;

      return position;
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // Update Cached Position
  // ============================================================

  /// تحديث الـ cached location يدويًا.
  ///
  /// مفيدة لو عندك Position جاي من Stream.
  static void updateCurrentPosition(Position position) {
    _currentPosition = position;
  }

  /// مسح الـ cached location.
  ///
  /// استخدمها فقط لو محتاج تجبر التطبيق
  /// يجيب Location جديدة.
  static void clearCurrentPosition() {
    _currentPosition = null;
  }

  // ============================================================
  // Position Stream
  // ============================================================

  /// متابعة تحركات المستخدم.
  ///
  /// كل 10 متر تقريبًا يعمل update.
  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).map((position) {
      // Update cached position automatically.
      _currentPosition = position;

      return position;
    });
  }

  // ============================================================
  // Settings
  // ============================================================

  /// فتح إعدادات التطبيق.
  ///
  /// يتم استدعاؤها فقط من الـ UI بعد ضغط المستخدم.
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// فتح إعدادات الـ Location/GPS.
  ///
  /// يتم استدعاؤها فقط من الـ UI بعد ضغط المستخدم.
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // ============================================================
  // Geocoding
  // ============================================================

  /// تحويل الإحداثيات إلى عنوان.
  static Future<String?> getAddressFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        return "${place.street}, "
            "${place.locality}, "
            "${place.country}";
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// تحويل الإحداثيات من String إلى عنوان.
  static Future<String?> getAddressFromLatLngStrings(String? lat, String? lng) async {
    if (lat == null || lng == null) {
      return null;
    }

    final latitude = double.tryParse(lat);
    final longitude = double.tryParse(lng);

    if (latitude == null || longitude == null) {
      return null;
    }

    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        return "${place.street}, "
            "${place.locality}, "
            "${place.country}";
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
