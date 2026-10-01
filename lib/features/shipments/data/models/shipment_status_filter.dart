import 'package:equatable/equatable.dart';

class ShipmentStatusFilter extends Equatable {
  const ShipmentStatusFilter({
    required this.id,
    required this.title,
    required this.titleAr,
  });

  final int id;
  final String title;
  final String titleAr;

  factory ShipmentStatusFilter.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['id']);
    final title = json['title'];
    final titleAr = json['title_ar'];
    if (id == null || title is! String || titleAr is! String) {
      throw const FormatException('Invalid status item in statuses response.');
    }
    return ShipmentStatusFilter(id: id, title: title, titleAr: titleAr);
  }

  String localizedTitle(String languageCode) =>
      languageCode == 'ar' ? titleAr : title;

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  List<Object?> get props => [id, title, titleAr];
}
