import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/state/app_state.dart';
import 'package:futureexpressapp/core/storage/local_preview_repository.dart';
import 'package:futureexpressapp/core/theme/cubit/app_theme_cubit.dart';
import 'package:futureexpressapp/features/home/data/models/home_summary.dart';
import 'package:futureexpressapp/features/home/presentation/widgets/home_card.dart';
import 'package:futureexpressapp/features/home/presentation/widgets/home_card_staus_list.dart';

class _MemoryRepository implements LocalPreviewRepository {
  @override
  Future<Map<String, dynamic>> read() async => {};

  @override
  Future<void> write(Map<String, dynamic> data) async {}
}

void main() {
  testWidgets('all home status cards have equal heights', (tester) async {
    final state = AppState(repository: _MemoryRepository())
      ..locale = const Locale('en', 'US');
    addTearDown(state.dispose);

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AppThemeCubit(),
        child: MaterialApp(
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeCardStatusList(state: state, onTab: (_) {}),
            ),
          ),
        ),
      ),
    );

    final heights = List.generate(
      find.byType(HomeCard).evaluate().length,
      (index) => tester.getSize(find.byType(HomeCard).at(index)).height,
    );

    expect(heights, hasLength(6));
    expect(heights.toSet(), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('home cards localize action labels and show concise metrics',
      (tester) async {
    final state = AppState(repository: _MemoryRepository())
      ..locale = const Locale('ar', 'SA');
    addTearDown(state.dispose);

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AppThemeCubit(),
        child: MaterialApp(
          locale: const Locale('ar', 'SA'),
          supportedLocales: const [
            Locale('ar', 'SA'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeCardStatusList(
                state: state,
                onTab: (_) {},
                useSummary: true,
                summary: const HomeSummary(
                  todayShipments: 52,
                  deliveredShipments: 3,
                  inDeliveryShipments: 49,
                  todayCollected: 393,
                  currency: '﷼',
                  shiftStatus: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('استلام الشحنات'), findsOneWidget);
    expect(find.text('عرض على الخريطة'), findsOneWidget);
    expect(find.text('52'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('49'), findsOneWidget);
    expect(find.text('52 Shipment'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(HomeCard).at(4),
        matching: find.byIcon(Icons.arrow_forward),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
