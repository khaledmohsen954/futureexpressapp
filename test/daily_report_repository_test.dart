import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/reports/data/models/daily_report.dart';
import 'package:futureexpressapp/features/reports/data/repositories/daily_report_repository.dart';

import 'helpers/fake_shipments_api.dart';

void main() {
  final reportResponse = {
    'success': 1,
    'message': 'تم الحفظ',
    'data': {
      'date': '2026-09-30',
      'date_formatted': 'الأربعاء، 30 سبتمبر',
      'date_formatted_ar': 'الأربعاء، ٣٠ سبتمبر',
      'day_name': 'الأربعاء',
      'currency': '﷼',
      'currency_code': 'SAR',
      'total_shipments': 20,
      'delivered_shipments': 15,
      'in_delivery_shipments': 3,
      'failed_shipments': 2,
      'cash_collected': 1500,
      'electronic_collected': 1000,
      'total_collected': 2500,
      'notes': null,
      'report_id': null,
    },
  };

  test('loads and maps the daily report summary', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      getResponses: {EndPoints.v3DailyReport: reportResponse},
    );

    final result = await DailyReportRepository(api).getDailyReport();

    expect(api.requestedPaths, [EndPoints.v3DailyReport]);
    expect(api.postedPath, isNull);
    expect(api.postedBody, isNull);
    result.fold(
      (_) => fail('Expected the summary to load.'),
      (report) {
        expect(report.message, 'تم الحفظ');
        expect(report.date, '2026-09-30');
        expect(report.dateFormatted, 'الأربعاء، 30 سبتمبر');
        expect(report.dateFormattedAr, 'الأربعاء، ٣٠ سبتمبر');
        expect(report.dayName, 'الأربعاء');
        expect(report.currencyCode, 'SAR');
        expect(report.totalShipments, 20);
        expect(report.deliveredShipments, 15);
        expect(report.inDeliveryShipments, 3);
        expect(report.failedShipments, 2);
        expect(report.cashCollected, 1500);
        expect(report.electronicCollected, 1000);
        expect(report.totalCollected, 2500);
        expect(report.notes, isNull);
        expect(report.reportId, isNull);
      },
    );
  });

  test('submits report summary and notes to submit-daily-report', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      postResponse: {'success': 1, 'message': 'Report submitted'},
    );
    final report = DailyReport.fromJson(reportResponse);
    final result = await DailyReportRepository(api).submitDailyReport(
      notes: 'Test daily report',
      clientId: 868,
      report: report,
    );

    expect(api.postedPath, EndPoints.v3SubmitDailyReport);
    expect(api.postedAsFormData, isFalse);
    expect(api.postedBody, {
      'notes': 'Test daily report',
      'date': '2026-09-30',
      'client_id': 868,
      'delivered_shipments': 15,
      'collected_amount': 2500,
      'cash_collected': 1500,
      'electronic_collected': 1000,
      'total_shipments': 20,
      'failed_shipments': 2,
      'in_delivery_shipments': 3,
      'Received': 15,
      'Recipient': 15,
      'Returned': 2,
      'total': 2500,
    });
    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected the report to submit.'),
      (message) => expect(message, 'Report submitted'),
    );
  });

  test('rejects a failed report submission', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      postResponse: {'success': 0, 'message': 'Report already submitted'},
    );

    final result = await DailyReportRepository(api).submitDailyReport(
      notes: '',
      clientId: 868,
      report: DailyReport.fromJson(reportResponse),
    );

    result.fold(
      (failure) => expect(failure.errMessage, 'Report already submitted'),
      (_) => fail('Expected an API failure.'),
    );
  });
}
