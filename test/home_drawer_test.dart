import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/core/state/app_state.dart';
import 'package:futureexpressapp/core/storage/local_preview_repository.dart';
import 'package:futureexpressapp/core/theme/cubit/app_theme_cubit.dart';
import 'package:futureexpressapp/features/home/data/repositories/home_summary_repository.dart';
import 'package:futureexpressapp/features/home/presentation/screens/home_screen.dart';

import 'helpers/fake_shipments_api.dart';

class _MemoryRepository implements LocalPreviewRepository {
  @override
  Future<Map<String, dynamic>> read() async => {};

  @override
  Future<void> write(Map<String, dynamic> data) async {}
}

void main() {
  testWidgets('home hamburger opens the navigation drawer', (tester) async {
    final state = AppState(repository: _MemoryRepository())
      ..locale = const Locale('en', 'US');
    addTearDown(state.dispose);
    final api = FakeShipmentsApiConsumer(
      const {},
      getResponses: {
        EndPoints.v3HomeSummary: {
          'success': 1,
          'today_shipments': 52,
          'delivered_shipments': 3,
          'in_delivery_shipments': 49,
          'today_collected': 393,
          'currency': '﷼',
          'shift_status': true,
        },
      },
    );

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AppThemeCubit(),
        child: MaterialApp(
          locale: const Locale('en', 'US'),
          supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
          home: AppScope(
            state: state,
            child: HomeScreen(
              onTab: _ignoreTab,
              repository: HomeSummaryRepository(api),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Shipment map'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('Help and support'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });
}

void _ignoreTab(int _) {}
