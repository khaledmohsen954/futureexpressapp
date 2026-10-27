import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futureexpressapp/core/utils/common_methods.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';
import 'package:futureexpressapp/features/shipments/presentation/cubit/shipment_status_cubit.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/location_requirement.dart';
import '../../../../core/widgets.dart';
import '../../../shipments/presentation/widgets/capture_status_image.dart';
import '../../../shipments/presentation/widgets/status_image_source_sheet.dart';

/// Figma 11:428 — records a failed delivery against the selected shipment.
class DeliveryFailureScreen extends StatefulWidget {
  const DeliveryFailureScreen({super.key, required this.shipment});
  final Shipment shipment;
  @override
  State<DeliveryFailureScreen> createState() => _DeliveryFailureScreenState();
}

class _DeliveryFailureScreenState extends State<DeliveryFailureScreen> {
  String? reasonKey;
  DateTime? _postponedDate;
  bool _isSubmitting = false;
  final note = TextEditingController();
  final reasons = const [
    AppLocaleKey.reasonUnavailable,
    AppLocaleKey.reasonAddress,
    AppLocaleKey.reasonRefused,
    AppLocaleKey.reasonPostponed,
    AppLocaleKey.reasonOther
  ];
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  void _selectReason(String? value) {
    if (value == null) return;
    setState(() {
      reasonKey = value;
      if (value != AppLocaleKey.reasonPostponed) _postponedDate = null;
    });
    if (value == AppLocaleKey.reasonPostponed) {
      unawaited(_pickPostponedDate());
    }
  }

  Future<void> _pickPostponedDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _postponedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 90)),
      builder: (pickerContext, child) => Theme(
        data: Theme.of(pickerContext).copyWith(
          colorScheme: Theme.of(pickerContext)
              .colorScheme
              .copyWith(primary: AppColors.red),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _postponedDate = picked);
  }

  Future<void> _submitFailure() async {
    if (_isSubmitting) return;
    if (reasonKey == null) {
      showLocalMessage(context, tr(context, AppLocaleKey.chooseReason));
      return;
    }
    if (reasonKey == AppLocaleKey.reasonPostponed && _postponedDate == null) {
      await _pickPostponedDate();
      if (!mounted) return;
      if (_postponedDate == null) {
        showLocalMessage(
          context,
          tr(context, AppLocaleKey.postponedDateRequired),
        );
        return;
      }
    }
    final source = await pickStatusImageSource(context);
    if (!mounted || source == null) return;
    setState(() => _isSubmitting = true);
    File? failureImage;
    try {
      failureImage = await captureStatusImage(context, source: source);
      if (!mounted || failureImage == null) return;
      final failureReason = tr(context, reasonKey!);
      final postponedDate = _postponedDate;
      final failureNotes = note.text.trim();
      final notes = [
        postponedDate == null
            ? failureReason
            : '$failureReason '
                '(${MaterialLocalizations.of(context).formatMediumDate(postponedDate)})',
        if (failureNotes.isNotEmpty) failureNotes,
      ].join(': ');
      final locationReady =
          await LocationRequirement.ensureForShipmentStatus(context);
      if (!mounted || !locationReady) return;
      final success = await context.read<ShipmentStatusCubit>().updateStatus(
        orderIds: [widget.shipment.id],
        statusId: ShipmentStatusApi.statusDeliveryFailed,
        notes: notes,
        failureImage: failureImage,
        delayDate: postponedDate?.toIso8601String().split('T').first,
        returnReason: failureReason,
      );
      if (!mounted) return;
      if (!success) {
        final state = context.read<ShipmentStatusCubit>().state;
        showLocalMessage(
          context,
          state.locationUnavailable
              ? tr(context, AppLocaleKey.shipmentStatusLocationRequired)
              : state.errorMessage ??
                  tr(context, AppLocaleKey.shipmentStatusUpdateFailed),
        );
        return;
      }
      AppScope.of(context).fail(
        widget.shipment.id,
        reasonKey!,
        failureNotes,
      );
      showLocalMessage(
        context,
        context.read<ShipmentStatusCubit>().state.successMessage ??
            tr(context, AppLocaleKey.failureSaved),
      );
      setState(() => _isSubmitting = false);
      Navigator.pop(context, true);
    } finally {
      await CommonMethods.cleanupStagingFiles([failureImage]);
      if (mounted && _isSubmitting) setState(() => _isSubmitting = false);
    }
  }

  Widget _postponedDateSubtitle(BuildContext context) {
    final date = _postponedDate;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(Icons.event_outlined, size: 16, color: AppColors.muted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              date == null
                  ? tr(context, AppLocaleKey.choosePostponedDate)
                  : '${tr(context, AppLocaleKey.postponedDate)}: '
                      '${MaterialLocalizations.of(context).formatMediumDate(date)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_isSubmitting,
        child: Scaffold(
          appBar:
              AppBar(title: Text(tr(context, AppLocaleKey.deliveryFailure))),
          body: PageBody(children: [
            SurfaceCard(
                child: Row(children: [
              const Icon(Icons.inventory_2_outlined, color: AppColors.red),
              const SizedBox(width: 12),
              Text('#${widget.shipment.orderId ?? widget.shipment.id}',
                  style: Theme.of(context).textTheme.labelLarge),
            ])),
            const SizedBox(height: 23),
            Text(tr(context, AppLocaleKey.reasonTitle),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            for (final key in reasons)
              Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SurfaceCard(
                      padding: EdgeInsets.zero,
                      child: Material(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        clipBehavior: Clip.antiAlias,
                        child: RadioListTile<String>(
                          title: Text(tr(context, key)),
                          subtitle: key == AppLocaleKey.reasonPostponed
                              ? _postponedDateSubtitle(context)
                              : null,
                          value: key,
                          // ignore: deprecated_member_use
                          groupValue: reasonKey,
                          activeColor: AppColors.red,
                          // ignore: deprecated_member_use
                          onChanged: _selectReason,
                        ),
                      ))),
            const SizedBox(height: 13),
            Text(tr(context, AppLocaleKey.notes),
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
                controller: note,
                maxLines: 3,
                decoration: InputDecoration(
                    hintText: tr(context, AppLocaleKey.extraDetails))),
            const SizedBox(height: 24),
            ActionButton(
                label: tr(context, AppLocaleKey.confirmFailure),
                icon: Icons.report_problem_outlined,
                isLoading: _isSubmitting ||
                    context.watch<ShipmentStatusCubit>().state.isLoading,
                onPressed: context.watch<ShipmentStatusCubit>().state.isLoading
                    ? null
                    : _isSubmitting
                        ? null
                        : () => unawaited(_submitFailure())),
          ]),
        ),
      );
}
