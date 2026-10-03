class LoginUser {
  const LoginUser({
    required this.apiToken,
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
  });

  final String apiToken;
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

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    final apiToken = json['api_token'];
    if (apiToken is! String || apiToken.isEmpty) {
      throw const FormatException('Login response is missing api_token.');
    }

    return LoginUser(
      apiToken: apiToken,
      id: _asInt(json['id']),
      code: json['code'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      shiftStatus: json['shift_status'] as bool?,
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
  }

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
    if (value is String) return int.tryParse(value);
    return null;
  }
}
