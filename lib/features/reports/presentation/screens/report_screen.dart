import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routes/routes_name.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/navigator_methods.dart';
import '../../../../core/widgets.dart';
import '../../../shipments/domain/shipment.dart';
import '../widgets/report_amount_row.dart';

/// Figma 11:250 — report totals are computed from current shipment statuses.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cash = state.collectedFor(PaymentMethod.cash);
    final online = state.collectedFor(PaymentMethod.online);
    final date = MaterialLocalizations.of(context).formatMediumDate(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, AppLocaleKey.dailyReport))),
      body: PageBody(children: [
        Text(tr(context, AppLocaleKey.todaySummary), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 5),
        Text(date, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 18),
        SurfaceCard(
            color: AppColors.navy,
            child: Column(children: [
              Text(tr(context, AppLocaleKey.totalCollection),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.onDarkMuted)),
              const SizedBox(height: 7),
              Money(state.totalCollected, color: AppColors.onDark, size: 31),
              const SizedBox(height: 8),
              Text(tr(context, AppLocaleKey.duringShift),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.onDarkMuted)),
            ])),
        const SizedBox(height: 17),
        Row(children: [
          Expanded(
              child: _ReportStat(Icons.inventory_2_outlined,
                  tr(context, AppLocaleKey.totalShipments), '${state.shipments.length}')),
          const SizedBox(width: 9),
          Expanded(
              child: _ReportStat(Icons.check_circle_outline, tr(context, AppLocaleKey.delivered),
                  '${state.count(ShipmentStatus.delivered)}')),
        ]),
        const SizedBox(height: 9),
        Row(children: [
          Expanded(
              child: _ReportStat(Icons.pending_actions_outlined,
                  tr(context, AppLocaleKey.inTransit), '${state.count(ShipmentStatus.inTransit)}')),
          const SizedBox(width: 9),
          Expanded(
              child: _ReportStat(
                  Icons.assignment_late_outlined,
                  tr(context, AppLocaleKey.deliveryFailure),
                  '${state.count(ShipmentStatus.failed)}')),
        ]),
        const SizedBox(height: 20),
        SectionTitle(tr(context, AppLocaleKey.collectionDetails)),
        const SizedBox(height: 7),
        SurfaceCard(
            child: Column(children: [
          ReportAmountRow(tr(context, AppLocaleKey.cashCollection), '$cash'),
          const Divider(),
          ReportAmountRow(tr(context, AppLocaleKey.onlineCollection), '$online'),
          const Divider(),
          ReportAmountRow(tr(context, AppLocaleKey.total), '${state.totalCollected}'),
        ])),
        const SizedBox(height: 22),
        ActionButton(
            label: tr(context, AppLocaleKey.sendDailyReport),
            icon: Icons.send_outlined,
            onPressed: () => NavigatorMethods.pushNamed(context, RoutesName.sendReportScreen)),
      ]),
    );
  }
}

/// Single metric card used four times by the report overview.
class _ReportStat extends StatelessWidget {
  const _ReportStat(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => SurfaceCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppColors.red),
        const SizedBox(height: 10),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ]));
}
