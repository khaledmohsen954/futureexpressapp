import 'package:futureexpressapp/features/auth/data/models/login_user.dart';

class UserProfile {
  const UserProfile({
    this.id,
    this.code,
    this.name,
    this.phone,
    this.email,
    this.shiftStatus,
    this.city,
    this.workType,
    this.successRate,
    this.completedShipments,
    this.nationalId,
    this.licenseNumber,
    this.licensePhoto,
    this.bankName,
    this.bankAccountNumber,
    this.avatar,
    this.localAvatarPath,
  });

  final int? id;
  final String? code;
  final String? name;
  final String? phone;
  final String? email;
  final bool? shiftStatus;
  final String? city;
  final int? workType;
  final num? successRate;
  final int? completedShipments;
  final String? nationalId;
  final String? licenseNumber;
  final String? licensePhoto;
  final String? bankName;
  final String? bankAccountNumber;
  final String? avatar;
  final String? localAvatarPath;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: _asInt(json['id']),
        code: json['code'] as String?,
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        shiftStatus: _asBool(json['shift_status']),
        city: json['city'] as String?,
        workType: _asInt(json['work_type']),
        successRate: json['success_rate'] as num?,
        completedShipments: _asInt(json['completed_shipments']),
        nationalId: json['national_id'] as String?,
        licenseNumber: json['license_number'] as String?,
        licensePhoto: json['license_photo'] as String?,
        bankName: json['bank_name'] as String?,
        bankAccountNumber: json['bank_account_number'] as String?,
        avatar: json['avatar'] as String?,
      );

  factory UserProfile.fromLoginUser(LoginUser user) => UserProfile(
        id: user.id,
        code: user.code,
        name: user.name,
        phone: user.phone,
        email: user.email,
        shiftStatus: user.shiftStatus,
        city: user.city,
        workType: user.workType,
        successRate: user.successRate,
        completedShipments: user.completedShipments,
        nationalId: user.nationalId,
        licenseNumber: user.licenseNumber,
        licensePhoto: user.licensePhoto,
        bankName: user.bankName,
        bankAccountNumber: user.bankAccountNumber,
        avatar: user.avatar,
      );

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? localAvatarPath,
  }) =>
      UserProfile(
        id: id,
        code: code,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        shiftStatus: shiftStatus,
        city: city,
        workType: workType,
        successRate: successRate,
        completedShipments: completedShipments,
        nationalId: nationalId,
        licenseNumber: licenseNumber,
        licensePhoto: licensePhoto,
        bankName: bankName,
        bankAccountNumber: bankAccountNumber,
        avatar: avatar ?? this.avatar,
        localAvatarPath: localAvatarPath ?? this.localAvatarPath,
      );

  Map<String, dynamic> toCacheMap() => {
        'id': id,
        'code': code,
        'name': name,
        'phone': phone,
        'email': email,
        'shift_status': shiftStatus,
        'city': city,
        'work_type': workType,
        'success_rate': successRate,
        'completed_shipments': completedShipments,
        'avatar': avatar,
      }..removeWhere((_, value) => value == null);

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      if (value == '1' || value.toLowerCase() == 'true') return true;
      if (value == '0' || value.toLowerCase() == 'false') return false;
    }
    return null;
  }
}
