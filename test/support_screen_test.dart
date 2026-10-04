import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/core/theme/cubit/app_theme_cubit.dart';
import 'package:futureexpressapp/features/support/data/repositories/app_settings_repository.dart';
import 'package:futureexpressapp/features/support/presentation/screens/support_screen.dart';

import 'helpers/fake_shipments_api.dart';

void main() {
  testWidgets('shows support contacts returned by app settings',
      (tester) async {
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
          },
        ],
      },
    );

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AppThemeCubit(),
        child: MaterialApp(
          locale: const Locale('en', 'US'),
          supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
          home: SupportScreen(repository: AppSettingsRepository(api)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('future'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('info@future.sa'), findsNWidgets(2));
    expect(find.text('0531938000'), findsNWidgets(2));
    expect(api.requestedPaths, [EndPoints.v3AppSettings]);
    expect(tester.takeException(), isNull);
  });
}
