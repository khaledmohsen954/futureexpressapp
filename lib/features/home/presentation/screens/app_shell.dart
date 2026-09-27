import 'package:flutter/material.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme.dart';
import '../../../reports/presentation/screens/report_screen.dart';
import '../../../shipments/presentation/screens/shipments_screen.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'home_screen.dart';

/// Navigation shell keeps tab selection while the shared state owns the data.
class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: index, children: [
      HomeScreen(onTab: (tab) => setState(() => index = tab)),
      const ShipmentsScreen(),
      const ReportScreen(),
      const WalletScreen(),
      const ProfileScreen(),
    ]),
    bottomNavigationBar: NavigationBar(
      height: 69, selectedIndex: index, backgroundColor: Colors.white,
      indicatorColor: AppColors.red.withValues(alpha: .1),
      onDestinationSelected: (tab) => setState(() => index = tab),
      destinations: [
        NavigationDestination(icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home, color: AppColors.red), label: tr(context, AppLocaleKey.home)),
        NavigationDestination(icon: const Icon(Icons.inventory_2_outlined),
          selectedIcon: const Icon(Icons.inventory_2, color: AppColors.red), label: tr(context, AppLocaleKey.shipments)),
        NavigationDestination(icon: const Icon(Icons.bar_chart_outlined),
          selectedIcon: const Icon(Icons.bar_chart, color: AppColors.red), label: tr(context, AppLocaleKey.reports)),
        NavigationDestination(icon: const Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: const Icon(Icons.account_balance_wallet, color: AppColors.red), label: tr(context, AppLocaleKey.wallet)),
        NavigationDestination(icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person, color: AppColors.red), label: tr(context, AppLocaleKey.profile)),
      ],
    ),
  );
}
