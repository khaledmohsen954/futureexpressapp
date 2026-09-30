import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';
import '../../../shipments/domain/shipment.dart';
import '../cubit/daily_report_cubit.dart';
import '../widgets/report_amount_row.dart';

/// Figma 11:288 — submits the daily report and displays the server summary.
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
    final reportState = context.watch<DailyReportCubit>().state;
    final report = reportState.report;
    final isArabic = state.locale.languageCode == 'ar';
    final reportDate = report == null
        ? null
        : isArabic
            ? report.dateFormattedAr ?? report.dateFormatted
            : report.dateFormatted;
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, AppLocaleKey.sendReport))),
      body: BlocListener<DailyReportCubit, DailyReportState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            (current.status == DailyReportStatus.failure ||
                current.status == DailyReportStatus.submitted),
        listener: (context, reportState) {
          if (reportState.status == DailyReportStatus.failure) {
            showLocalMessage(
              context,
              reportState.errorMessage ??
                  tr(context, AppLocaleKey.reportSubmitFailed),
            );
            return;
          }
          final submittedMessage = reportState.successMessage;
          state.sendReport(notes.text.trim());
          showLocalMessage(
            context,
            submittedMessage ?? tr(context, AppLocaleKey.reportSaved),
          );
        },
        child: PageBody(children: [
          Text(tr(context, AppLocaleKey.reviewReport),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          if (reportState.isLoadingSummary) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 10),
          ] else if (reportState.status == DailyReportStatus.failure &&
              report == null) ...[
            Text(
              reportState.errorMessage ??
                  tr(context, AppLocaleKey.reportSubmitFailed),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.red),
            ),
            TextButton(
              onPressed: () => context.read<DailyReportCubit>().loadSummary(),
              child: Text(tr(context, AppLocaleKey.retry)),
            ),
          ],
          if (reportDate != null) ...[
            Text(reportDate, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
          ],
          SurfaceCard(
              child: Column(children: [
            ReportAmountRow(
              tr(context, AppLocaleKey.totalShipments),
              '${report?.totalShipments ?? state.shipments.length}',
              isCurrency: false,
            ),
            const Divider(),
            ReportAmountRow(
              tr(context, AppLocaleKey.deliveredShipments),
              '${report?.deliveredShipments ?? state.count(ShipmentStatus.delivered)}',
              isCurrency: false,
            ),
            const Divider(),
            ReportAmountRow(
              tr(context, AppLocaleKey.inTransit),
              '${report?.inDeliveryShipments ?? state.count(ShipmentStatus.inTransit)}',
              isCurrency: false,
            ),
            const Divider(),
            ReportAmountRow(
              tr(context, AppLocaleKey.deliveryFailure),
              '${report?.failedShipments ?? state.count(ShipmentStatus.failed)}',
              isCurrency: false,
            ),
            const Divider(),
            ReportAmountRow(
              tr(context, AppLocaleKey.cashCollection),
              report?.formattedCashCollected ??
                  '${state.collectedFor(PaymentMethod.cash)}',
            ),
            const Divider(),
            ReportAmountRow(
              tr(context, AppLocaleKey.onlineCollection),
              report?.formattedElectronicCollected ??
                  '${state.collectedFor(PaymentMethod.online)}',
            ),
            const Divider(),
            ReportAmountRow(
              tr(context, AppLocaleKey.collectedAmount),
              report?.formattedTotalCollected ?? '${state.totalCollected}',
            ),
          ])),
          const SizedBox(height: 22),
          Text(tr(context, AppLocaleKey.notes),
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: notes,
            maxLines: 4,
            enabled: !reportState.isSubmitting &&
                reportState.status != DailyReportStatus.submitted,
            decoration: InputDecoration(
              hintText: tr(context, AppLocaleKey.notesHint),
            ),
          ),
          const SizedBox(height: 24),
          ActionButton(
            label: reportState.status == DailyReportStatus.submitting
                ? tr(context, AppLocaleKey.sendingReport)
                : reportState.status == DailyReportStatus.submitted
                    ? tr(context, AppLocaleKey.reportSent)
                    : tr(context, AppLocaleKey.confirmSend),
            icon: reportState.status == DailyReportStatus.submitting
                ? Icons.hourglass_top
                : reportState.status == DailyReportStatus.submitted
                    ? Icons.check_circle_outline
                    : Icons.send_outlined,
            color: reportState.status == DailyReportStatus.submitted
                ? AppColors.green
                : AppColors.red,
            onPressed: reportState.isSubmitting ||
                    report == null ||
                    reportState.status == DailyReportStatus.submitted
                ? null
                : () {
                    final clientId = state.clientId;
                    if (clientId == null) {
                      showLocalMessage(
                        context,
                        tr(context, AppLocaleKey.reportClientIdMissing),
                      );
                      return;
                    }
                    context.read<DailyReportCubit>().submit(
                          notes: notes.text.trim(),
                          clientId: clientId,
                        );
                  },
          ),
        ]),
      ),
    );
  }
}
