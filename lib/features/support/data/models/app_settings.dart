class AppSettings {
  const AppSettings({
    required this.name,
    required this.email,
    required this.phone,
    required this.currency,
    required this.orderNumberCharacters,
    this.androidMinVersion,
    this.iosMinVersion,
  });

  final String name;
  final String email;
  final String phone;
  final String currency;
  final String orderNumberCharacters;
  final String? androidMinVersion;
  final String? iosMinVersion;

  static AppSettings fromJson(Map<String, dynamic> json) {
    return AppSettings(
      name: _requiredString(json['name'], 'name'),
      email: _requiredString(json['email'], 'email'),
      phone: _requiredString(json['phone'], 'phone'),
      currency: _requiredString(json['currency'], 'currency'),
      orderNumberCharacters: _requiredString(
          json['order_number_characters'], 'order_number_characters'),
      androidMinVersion: _optionalString(json['android_min_version']),
      iosMinVersion: _optionalString(json['ios_min_version']),
    );
  }

  static String _requiredString(dynamic value, String field) {
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('App settings response is missing $field.');
  }

  static String? _optionalString(dynamic value) {
    if (value == null) return null;
    if (value is String && value.trim().isNotEmpty) return value.trim();
    throw const FormatException('App settings contains an invalid app version.');
  }
}
