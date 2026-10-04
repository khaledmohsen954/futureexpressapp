import 'package:flutter/material.dart';
import 'package:futureexpressapp/features/scanner/presentation/screen/scanner_screen.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme.dart';
import '../../../reports/presentation/screens/report_screen.dart';
import '../../../shipments/presentation/screens/shipments_screen.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';
import 'home_screen.dart';

/// Navigation shell keeps tab selection while the shared state owns the data.
class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  /// أيقونة السكانر: تحجز مساحة 24×24 زي باقي الأيقونات عشان الليبلز
  /// تبقى على نفس الخط، والكونتينر نفسه بيطلع لفوق بـ Transform.translate.
  Widget _scanIcon(IconData icon) => SizedBox(
        width: 24,
        height: 24,
        child: OverflowBox(
          maxWidth: 52,
          maxHeight: 52,
          child: Transform.translate(
            offset: const Offset(0, -14), // زوّد الرقم لو عايزه أعلى
            child: Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                    color: AppColors.red.withValues(alpha: .2), width: 1),
              ),
              child: Icon(icon, color: AppColors.onDark),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: index, children: [
          HomeScreen(onTab: (tab) => setState(() => index = tab)),
          const ShipmentsScreen(),
          ScannerScreen(isActive: index == 2),
          const ReportScreen(),
          const WalletScreen(),
        ]),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              indicatorColor: index == 2
                  ? Colors.transparent
                  : AppColors.red.withValues(alpha: .1),
            ),
          ),
          child: NavigationBar(
            height: 76,
            selectedIndex: index,
            backgroundColor: AppColors.surface,
            labelTextStyle: WidgetStateProperty.fromMap(
              {
                WidgetState.selected:
                    Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.red,
                          fontWeight: FontWeight.w700,
                        ),
              },
            ),
            // indicatorColor: AppColors.red.withValues(alpha: .1),
            onDestinationSelected: (tab) => setState(() => index = tab),
            destinations: [
              NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home, color: AppColors.red),
                  label: tr(context, AppLocaleKey.home)),
              NavigationDestination(
                  icon: const Icon(Icons.inventory_2_outlined),
                  selectedIcon:
                      const Icon(Icons.inventory_2, color: AppColors.red),
                  label: tr(context, AppLocaleKey.shipments)),
              NavigationDestination(
                  icon: _scanIcon(Icons.qr_code_scanner_outlined),
                  selectedIcon: _scanIcon(Icons.qr_code_scanner),
                  label: tr(context, AppLocaleKey.scanQr)),
              NavigationDestination(
                  icon: const Icon(Icons.bar_chart_outlined),
                  selectedIcon:
                      const Icon(Icons.bar_chart, color: AppColors.red),
                  label: tr(context, AppLocaleKey.reports)),
              NavigationDestination(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: const Icon(Icons.account_balance_wallet,
                      color: AppColors.red),
                  label: tr(context, AppLocaleKey.wallet)),
            ],
          ),
        ),
      );
}
