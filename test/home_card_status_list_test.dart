import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/state/app_state.dart';
import 'package:futureexpressapp/core/storage/local_preview_repository.dart';
import 'package:futureexpressapp/core/theme/cubit/app_theme_cubit.dart';
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
}
