import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';

import '../../features/auth/data/repositories/logout_repository.dart';
import '../../features/home/data/repositories/shift_repository.dart';
import '../../features/profile/data/models/user_profile.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/shipments/data/sample_shipments.dart';
import '../../features/shipments/domain/shipment.dart';
import '../cache/hive/hive_methods.dart';
import '../error/failures.dart';
import '../storage/local_preview_repository.dart';

/// Central state: shipment actions update every dependent screen and local storage.
class AppState extends ChangeNotifier {
  AppState({
    LocalPreviewRepository? repository,
  }) : _repository = repository ?? LocalPreviewRepository();
  final LocalPreviewRepository _repository;
  final List<Shipment> _shipments = List.of(sampleShipments);
  Future<void> _pendingWrite = Future.value();

  List<Shipment> get shipments => List.unmodifiable(_shipments);
  bool signedIn = false;
  bool onDuty = false;
  bool isUpdatingDuty = false;
  bool reportSent = false;
  String reportNotes = '';
  String phone = '';
  int? clientId;
  String? name;
  String? email;
  String? city;
  UserProfile? userProfile;
  bool isCheckingProfile = false;
  String? profileLoadError;
  Locale locale = const Locale('ar', 'SA');
  final Map<String, String> failureReasons = {};
  final Map<String, String> failureNotes = {};
  final Set<String> pickedUpIds = {};

  int count(ShipmentStatus status) =>
      _shipments.where((s) => s.status == status).length;
  int get totalCollected => _shipments
      .where((s) => s.status == ShipmentStatus.delivered)
      .fold<int>(0, (total, shipment) => total + shipment.amount);
  int collectedFor(PaymentMethod method) => _shipments
      .where((s) =>
          s.status == ShipmentStatus.delivered && s.paymentMethod == method)
      .fold<int>(0, (total, shipment) => total + shipment.amount);
  int get pendingAmount => _shipments
      .where((s) =>
          s.status != ShipmentStatus.delivered &&
          s.status != ShipmentStatus.failed)
      .fold<int>(0, (total, shipment) => total + shipment.amount);

  /// Restore the demo's language, status changes, pickup history and report.
  Future<void> restore() async {
    final saved = await _repository.read();
    final token = HiveMethods.getToken();
    final userData = HiveMethods.getUserData();
    signedIn = token != null && token.isNotEmpty;
    if (userData != null) {
      userProfile = UserProfile.fromJson(userData);
      clientId = _asInt(userData['id']);
      name = userData['name'] as String?;
      phone = userData['phone'] as String? ?? '';
      email = userData['email'] as String?;
      city = userData['city'] as String?;
    }
    if (saved['language'] == 'en') locale = const Locale('en', 'US');
    onDuty = HiveMethods.getShiftStatus() ??
        _asBool(userData?['shift_status']) ??
        (saved['onDuty'] == true);
    reportSent = saved['reportSent'] == true;
    reportNotes =
        saved['reportNotes'] is String ? saved['reportNotes'] as String : '';
    if (saved['pickedUp'] is List) {
      pickedUpIds.addAll((saved['pickedUp'] as List).whereType<String>());
    }
    if (saved['failureReasons'] is Map) {
      (saved['failureReasons'] as Map).forEach((key, value) {
        if (key is String && value is String) failureReasons[key] = value;
      });
    }
    if (saved['failureNotes'] is Map) {
      (saved['failureNotes'] as Map).forEach((key, value) {
        if (key is String && value is String) failureNotes[key] = value;
      });
    }
    if (saved['statuses'] is Map) {
      final statuses = saved['statuses'] as Map;
      for (var index = 0; index < _shipments.length; index++) {
        final statusName = statuses[_shipments[index].id];
        for (final status in ShipmentStatus.values) {
          if (status.name == statusName) {
            _shipments[index] = _shipments[index].copyWith(status: status);
            break;
          }
        }
      }
    }
    notifyListeners();
  }

  /// Queue snapshots to keep consecutive edits in the order they happened.
  void _changed() {
    notifyListeners();
    final snapshot = <String, dynamic>{
      'language': locale.languageCode,
      'onDuty': onDuty,
      'reportSent': reportSent,
      'reportNotes': reportNotes,
      'pickedUp': pickedUpIds.toList(),
      'failureReasons': Map.of(failureReasons),
      'failureNotes': Map.of(failureNotes),
      'statuses': {for (final s in _shipments) s.id: s.status.name},
    };
    _pendingWrite = _pendingWrite.then((_) => _repository.write(snapshot));
  }

  void signIn({
    required String phone,
    int? clientId,
    String? name,
    String? email,
    String? city,
    UserProfile? profile,
  }) {
    this.phone = phone;
    this.clientId = clientId;
    this.name = name;
    this.email = email;
    this.city = city;
    userProfile = profile ??
        UserProfile(name: name, phone: phone, email: email, city: city);
    onDuty = profile?.shiftStatus ?? onDuty;
    profileLoadError = null;
    isCheckingProfile = false;
    signedIn = true;
    notifyListeners();
  }

  Future<void> refreshProfile(ProfileRepository repository) async {
    if (!signedIn || isCheckingProfile) return;
    isCheckingProfile = true;
    profileLoadError = null;
    notifyListeners();

    final result = await repository.getProfile();
    if (!signedIn) return;
    final failure = result.fold<Failure?>((failure) => failure, (_) => null);
    if (failure != null) {
      isCheckingProfile = false;
      profileLoadError = failure.errMessage;
      notifyListeners();
      return;
    }
    final profile =
        result.fold<UserProfile?>((_) => null, (profile) => profile);
    await setUserProfile(profile!);
    isCheckingProfile = false;
    profileLoadError = null;
    notifyListeners();
  }

  Future<void> setUserProfile(UserProfile profile) async {
    userProfile = profile;
    clientId = profile.id ?? clientId;
    name = profile.name;
    phone = profile.phone ?? phone;
    email = profile.email;
    city = profile.city;
    onDuty = profile.shiftStatus ?? onDuty;
    await HiveMethods.updateUserData(profile.toCacheMap());
    await HiveMethods.updateShiftStatus(onDuty);
    notifyListeners();
  }

  void syncShiftStatus(bool value) {
    if (onDuty == value) return;
    onDuty = value;
    notifyListeners();
  }

  Future<Either<Failure, Unit>> signOut(LogoutRepository repository) async {
    final result = await repository.logout();
    await HiveMethods.deleteToken();
    await HiveMethods.deleteUserData();
    signedIn = false;
    phone = '';
    clientId = null;
    name = null;
    email = null;
    city = null;
    userProfile = null;
    profileLoadError = null;
    isCheckingProfile = false;
    notifyListeners();
    return result;
  }

  Future<void> expireSession() async {
    await HiveMethods.deleteToken();
    await HiveMethods.deleteUserData();
    signedIn = false;
    phone = '';
    clientId = null;
    name = null;
    email = null;
    city = null;
    userProfile = null;
    profileLoadError = null;
    isCheckingProfile = false;
    notifyListeners();
  }

  void toggleLanguage() {
    locale = locale.languageCode == 'ar'
        ? const Locale('en', 'US')
        : const Locale('ar', 'SA');
    _changed();
  }

  Future<Either<Failure, Unit>> setDuty(
    bool value,
    ShiftRepository repository,
  ) async {
    if (isUpdatingDuty || onDuty == value) return const Right(unit);
    final previousValue = onDuty;
    onDuty = value;
    isUpdatingDuty = true;
    _changed();
    await HiveMethods.updateShiftStatus(value);
    try {
      final result = await repository.updateShift(value);
      final failure = result.fold<Failure?>((failure) => failure, (_) => null);
      if (failure != null) {
        onDuty = previousValue;
        _changed();
        await HiveMethods.updateShiftStatus(previousValue);
        return result;
      }
      reportSent = false;
      _changed();
      return result;
    } finally {
      isUpdatingDuty = false;
      notifyListeners();
    }
  }

  /// A simulated scan moves the next waiting shipment to in-transit.
  Shipment? pickupNext() {
    final index =
        _shipments.indexWhere((s) => s.status == ShipmentStatus.inTransit);
    if (index < 0) return null;
    final shipment = _shipments[index];
    _shipments[index] = shipment.copyWith(status: ShipmentStatus.delivered);
    pickedUpIds.add(shipment.id);
    reportSent = false;
    _changed();
    return _shipments[index];
  }

  /// Confirmed delivery updates the wallet and report totals immediately.
  bool deliver(String id) {
    final index = _shipments
        .indexWhere((s) => s.id == id && s.status == ShipmentStatus.inTransit);
    if (index < 0) return false;
    _shipments[index] =
        _shipments[index].copyWith(status: ShipmentStatus.delivered);
    reportSent = false;
    _changed();
    return true;
  }

  void fail(String id, String reasonKey, String notes) {
    final index = _shipments.indexWhere((shipment) => shipment.id == id);
    if (index >= 0) {
      if (_shipments[index].status == ShipmentStatus.delivered) return;
      _shipments[index] =
          _shipments[index].copyWith(status: ShipmentStatus.failed);
    }
    failureReasons[id] = reasonKey;
    failureNotes[id] = notes;
    reportSent = false;
    _changed();
  }

  void sendReport(String notes) {
    reportNotes = notes;
    reportSent = true;
    _changed();
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      if (value == '1' || value.toLowerCase() == 'true') return true;
      if (value == '0' || value.toLowerCase() == 'false') return false;
    }
    return null;
  }
}

/// Routes obtain the same AppState and rebuild after its notifications.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);
  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is required above every screen');
    return scope!.notifier!;
  }
}
