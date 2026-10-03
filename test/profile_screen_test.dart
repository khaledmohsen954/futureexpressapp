import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/state/app_state.dart';
import 'package:futureexpressapp/core/storage/local_preview_repository.dart';
import 'package:futureexpressapp/features/profile/data/models/user_profile.dart';
import 'package:futureexpressapp/features/profile/presentation/screens/profile_screen.dart';

void main() {
  testWidgets('shows API profile fields and profile update action',
      (tester) async {
    final state = AppState(repository: _MemoryRepository())
      ..locale = const Locale('en', 'US')
      ..userProfile = const UserProfile(
        code: '8944622',
        name: 'Khaled Delegate',
        phone: '0560498239',
        email: 'khaled@gmail.com',
        city: 'Alihsa',
        completedShipments: 78,
        successRate: 0,
        nationalId: '123213',
        licenseNumber: '154986523',
        bankName: 'Al Rajhi',
        bankAccountNumber: '45846131313161',
      );
    addTearDown(state.dispose);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
        home: AppScope(state: state, child: const ProfileScreen()),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('Update profile'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Khaled Delegate'), findsWidgets);
    expect(find.text('khaled@gmail.com'), findsOneWidget);
    expect(find.text('45846131313161'), findsOneWidget);
    expect(find.text('Update profile'), findsOneWidget);
  });
}

class _MemoryRepository implements LocalPreviewRepository {
  @override
  Future<Map<String, dynamic>> read() async => {};

  @override
  Future<void> write(Map<String, dynamic> data) async {}
}
