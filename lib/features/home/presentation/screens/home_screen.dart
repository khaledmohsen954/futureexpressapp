import 'package:flutter/material.dart';
import 'package:futureexpressapp/features/home/presentation/widgets/home_app_bar_methoud.dart';
import 'package:futureexpressapp/features/home/presentation/widgets/home_card_staus_list.dart';
import 'package:futureexpressapp/features/home/presentation/widgets/home_drawer.dart';
import 'package:futureexpressapp/features/home/presentation/widgets/home_shift_status_card.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/widgets.dart';

/// Figma 11:23 — statistics derive from the live local shipment list.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onTab});
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final recent = state.shipments.first;
    final english = state.locale.languageCode == 'en';
    return Scaffold(
      drawer: HomeDrawer(state: state),
      appBar: buildHomeAppBar(context),
      body: PageBody(children: [
        Text(tr(context, AppLocaleKey.welcome), style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 15),
        ShiftStatusCard(state: state),
        const SizedBox(height: 15),
        //HomePickupCard(),
        const SizedBox(height: 19),
        HomeCardStatusList(state: state, onTab: onTab),
        const SizedBox(height: 20),
        const SizedBox(height: 17),
        // SectionTitle(tr(context, AppLocaleKey.recentShipments),
        //     action: tr(context, AppLocaleKey.seeAll), onAction: () => onTab(1)),
        // const SizedBox(height: 8),
        // HomeOrderCard(recent: recent, english: english),
      ]),
    );
  }
}
