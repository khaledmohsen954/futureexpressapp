import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routes/routes_name.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/navigator_methods.dart';
import '../../../../core/widgets.dart';
import '../../../shipments/domain/shipment.dart';
import '../../data/repositories/daily_report_repository.dart';
import '../cubit/daily_report_cubit.dart';
import '../widgets/report_amount_row.dart';

/// Report overview populated from the server's daily summary.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => DailyReportCubit(
          repository: sl<DailyReportRepository>(),
        )..loadSummary(),
        child: const _ReportView(),
      );
}

class _ReportView extends StatelessWidget {
  const _ReportView();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final reportState = context.watch<DailyReportCubit>().state;
    final report = reportState.report;
    final isArabic = state.locale.languageCode == 'ar';
    final date = report == null
        ? MaterialLocalizations.of(context).formatMediumDate(DateTime.now())
        : isArabic
            ? report.dateFormattedAr ??
                report.dateFormatted ??
                report.date ??
                ''
            : report.dateFormatted ?? report.date ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, AppLocaleKey.dailyReport))),
      body: PageBody(children: [
        Text(tr(context, AppLocaleKey.todaySummary),
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 5),
        Text(date, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        if (reportState.isLoadingSummary)
          const Center(child: CircularProgressIndicator())
        else if (reportState.status == DailyReportStatus.failure &&
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
        SurfaceCard(
          color: AppColors.navy,
          child: Column(children: [
            Text(
              tr(context, AppLocaleKey.totalCollection),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.onDarkMuted),
            ),
            const SizedBox(height: 7),
            Money(
              report?.formattedTotalCollected ?? state.totalCollected,
              color: AppColors.onDark,
              size: 31,
            ),
            const SizedBox(height: 8),
            Text(
              tr(context, AppLocaleKey.duringShift),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.onDarkMuted),
            ),
          ]),
        ),
        const SizedBox(height: 17),
        Row(children: [
          Expanded(
            child: _ReportStat(
              Icons.inventory_2_outlined,
              tr(context, AppLocaleKey.totalShipments),
              '${report?.totalShipments ?? state.shipments.length}',
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _ReportStat(
              Icons.check_circle_outline,
              tr(context, AppLocaleKey.delivered),
              '${report?.deliveredShipments ?? state.count(ShipmentStatus.delivered)}',
            ),
          ),
        ]),
        const SizedBox(height: 9),
        Row(children: [
          Expanded(
            child: _ReportStat(
              Icons.pending_actions_outlined,
              tr(context, AppLocaleKey.inTransit),
              '${report?.inDeliveryShipments ?? state.count(ShipmentStatus.inTransit)}',
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _ReportStat(
              Icons.assignment_late_outlined,
              tr(context, AppLocaleKey.deliveryFailure),
              '${report?.failedShipments ?? state.count(ShipmentStatus.failed)}',
            ),
          ),
        ]),
        const SizedBox(height: 20),
        SectionTitle(tr(context, AppLocaleKey.collectionDetails)),
        const SizedBox(height: 7),
        SurfaceCard(
          child: Column(children: [
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
              tr(context, AppLocaleKey.total),
              report?.formattedTotalCollected ?? '${state.totalCollected}',
            ),
          ]),
        ),
        const SizedBox(height: 22),
        ActionButton(
          label: tr(context, AppLocaleKey.sendDailyReport),
          icon: Icons.send_outlined,
          onPressed: report == null
              ? null
              : () => NavigatorMethods.pushNamed(
                    context,
                    RoutesName.sendReportScreen,
                    arguments: report,
                  ),
        ),
      ]),
    );
  }
}

class _ReportStat extends StatelessWidget {
  const _ReportStat(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SurfaceCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: AppColors.red),
          const SizedBox(height: 10),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ]),
      );
}
