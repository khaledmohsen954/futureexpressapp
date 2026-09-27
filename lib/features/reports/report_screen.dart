import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/state/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../shipments/models/shipment.dart';
import 'send_report_screen.dart';
import 'widgets/report_amount_row.dart';

/// Figma 11:250 — report totals are computed from current shipment statuses.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cash = state.collectedFor(PaymentMethod.cash);
    final online = state.collectedFor(PaymentMethod.online);
    final date = MaterialLocalizations.of(context).formatMediumDate(DateTime.now());
    return Scaffold(appBar: AppBar(title: Text(tr(context, 'dailyReport'))),
      body: PageBody(children: [
        Text(tr(context, 'todaySummary'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text(date, style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 18),
        SurfaceCard(color: AppColors.navy, child: Column(children: [
          Text(tr(context, 'totalCollection'), style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 7), Money(state.totalCollected, color: Colors.white, size: 31),
          const SizedBox(height: 8), Text(tr(context, 'duringShift'),
            style: const TextStyle(color: Colors.white70)),
        ])),
        const SizedBox(height: 17),
        Row(children: [
          Expanded(child: _ReportStat(Icons.inventory_2_outlined, tr(context, 'totalShipments'), '${state.shipments.length}')),
          const SizedBox(width: 9),
          Expanded(child: _ReportStat(Icons.check_circle_outline, tr(context, 'delivered'), '${state.count(ShipmentStatus.delivered)}')),
        ]),
        const SizedBox(height: 9),
        Row(children: [
          Expanded(child: _ReportStat(Icons.pending_actions_outlined, tr(context, 'inTransit'), '${state.count(ShipmentStatus.inTransit)}')),
          const SizedBox(width: 9),
          Expanded(child: _ReportStat(Icons.assignment_late_outlined, tr(context, 'deliveryFailure'), '${state.count(ShipmentStatus.failed)}')),
        ]),
        const SizedBox(height: 20),
        SectionTitle(tr(context, 'collectionDetails')),
        const SizedBox(height: 7),
        SurfaceCard(child: Column(children: [
          ReportAmountRow(tr(context, 'cashCollection'), '$cash'),
          const Divider(), ReportAmountRow(tr(context, 'onlineCollection'), '$online'),
          const Divider(), ReportAmountRow(tr(context, 'total'), '${state.totalCollected}'),
        ])),
        const SizedBox(height: 22),
        ActionButton(label: tr(context, 'sendDailyReport'), icon: Icons.send_outlined,
          onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SendReportScreen()))),
      ]),
    );
  }
}

/// Single metric card used four times by the report overview.
class _ReportStat extends StatelessWidget {
  const _ReportStat(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;
  @override Widget build(BuildContext context) => SurfaceCard(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: AppColors.red), const SizedBox(height: 10),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
    ]));
}
