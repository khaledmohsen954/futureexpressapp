import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/support/data/repositories/app_settings_repository.dart';

import 'helpers/fake_shipments_api.dart';

void main() {
  test('loads public app settings including optional minimum versions', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      getResponses: {
        EndPoints.v3AppSettings: [
          {
            'id': 1,
            'name': 'future',
            'email': 'info@future.sa',
            'phone': '0531938000',
            'currency': 'ريال',
            'order_number_characters': 'ORD',
            'android_min_version': '1.0.7',
            'ios_min_version': '1.0.8',
          },
        ],
      },
    );

    final result = await AppSettingsRepository(api).getAppSettings();

    expect(api.requestedPaths, [EndPoints.v3AppSettings]);
    expect(api.requestedAuth, [false]);
    result.fold(
      (_) => fail('Expected app settings to load.'),
      (settings) {
        expect(settings.name, 'future');
        expect(settings.email, 'info@future.sa');
        expect(settings.phone, '0531938000');
        expect(settings.currency, 'ريال');
        expect(settings.orderNumberCharacters, 'ORD');
        expect(settings.androidMinVersion, '1.0.7');
        expect(settings.iosMinVersion, '1.0.8');
      },
    );
  });

  test('rejects an empty app settings response', () async {
    final api = FakeShipmentsApiConsumer(
      const {},
      getResponses: {EndPoints.v3AppSettings: []},
    );

    final result = await AppSettingsRepository(api).getAppSettings();

    expect(result.isLeft(), isTrue);
  });
}
