import 'package:flutter/material.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';
import '../../../shipments/domain/shipment.dart';
import '../widgets/report_amount_row.dart';

/// Figma 11:288 — sends a local report snapshot after showing current totals.
class SendReportScreen extends StatefulWidget {
  const SendReportScreen({super.key});
  @override
  State<SendReportScreen> createState() => _SendReportScreenState();
}

class _SendReportScreenState extends State<SendReportScreen> {
  final notes = TextEditingController();
  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, AppLocaleKey.sendReport))),
      body: PageBody(children: [
        Text(tr(context, AppLocaleKey.reviewReport),
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        SurfaceCard(
            child: Column(children: [
          ReportAmountRow(tr(context, AppLocaleKey.deliveredShipments),
              '${state.count(ShipmentStatus.delivered)}',
              isCurrency: false),
          const Divider(),
          ReportAmountRow(tr(context, AppLocaleKey.collectedAmount),
              '${state.totalCollected}'),
        ])),
        const SizedBox(height: 22),
        Text(tr(context, AppLocaleKey.notes),
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextField(
            controller: notes,
            maxLines: 4,
            decoration:
                InputDecoration(hintText: tr(context, AppLocaleKey.notesHint))),
        const SizedBox(height: 24),
        ActionButton(
            label: tr(
                context,
                state.reportSent
                    ? AppLocaleKey.reportSent
                    : AppLocaleKey.confirmSend),
            icon: state.reportSent
                ? Icons.check_circle_outline
                : Icons.send_outlined,
            color: state.reportSent ? AppColors.green : AppColors.red,
            onPressed: state.reportSent
                ? null
                : () {
                    state.sendReport(notes.text.trim());
                    showLocalMessage(
                        context, tr(context, AppLocaleKey.reportSaved));
                  }),
      ]),
    );
  }
}
