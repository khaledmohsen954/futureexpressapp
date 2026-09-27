import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../reports/report_screen.dart';
import '../shipments/shipments_screen.dart';
import '../wallet/wallet_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

/// Navigation shell for the five main tabs in the courier app.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.onSignOut});
  final VoidCallback onSignOut;
  @override State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  @override Widget build(BuildContext context) {
    final screens = [HomeScreen(onTab: (tab) => setState(() => index = tab)), const ShipmentsScreen(), const ReportScreen(), const WalletScreen(), ProfileScreen(onSignOut: widget.onSignOut)];
    return Scaffold(body: IndexedStack(index: index, children: screens), bottomNavigationBar: NavigationBar(
      height: 69, selectedIndex: index, backgroundColor: Colors.white, indicatorColor: AppColors.red.withValues(alpha: .1),
      onDestinationSelected: (tab) => setState(() => index = tab), destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: AppColors.red), label: 'الرئيسية'),
        NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2, color: AppColors.red), label: 'الشحنات'),
        NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart, color: AppColors.red), label: 'التقارير'),
        NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.red), label: 'المحفظة'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppColors.red), label: 'حسابي'),
      ]));
  }
}
