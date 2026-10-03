import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';
import 'package:futureexpressapp/features/shipments/presentation/cubit/shipment_status_cubit.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/location_requirement.dart';
import '../../../../core/widgets.dart';

/// Figma 11:428 — records a failed delivery against the selected shipment.
class DeliveryFailureScreen extends StatefulWidget {
  const DeliveryFailureScreen({super.key, required this.shipment});
  final Shipment shipment;
  @override
  State<DeliveryFailureScreen> createState() => _DeliveryFailureScreenState();
}

class _DeliveryFailureScreenState extends State<DeliveryFailureScreen> {
  String? reasonKey;
  final note = TextEditingController();
  final reasons = const [
    AppLocaleKey.reasonUnavailable,
    AppLocaleKey.reasonAddress,
    AppLocaleKey.reasonRefused,
    AppLocaleKey.reasonOther
  ];
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(tr(context, AppLocaleKey.deliveryFailure))),
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
                        value: key,
                        // ignore: deprecated_member_use
                        groupValue: reasonKey,
                        activeColor: AppColors.red,
                        // ignore: deprecated_member_use
                        onChanged: (value) => setState(() => reasonKey = value),
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
              onPressed: context.watch<ShipmentStatusCubit>().state.isLoading
                  ? null
                  : () async {
                      if (reasonKey == null) {
                        showLocalMessage(
                            context, tr(context, AppLocaleKey.chooseReason));
                        return;
                      }
                      final failureReason = tr(context, reasonKey!);
                      final failureNotes = note.text.trim();
                      final notes = [
                        failureReason,
                        if (failureNotes.isNotEmpty) failureNotes,
                      ].join(': ');
                      final locationReady =
                          await LocationRequirement.ensureForShipmentStatus(
                        context,
                      );
                      if (!context.mounted || !locationReady) return;
                      final success = await context
                          .read<ShipmentStatusCubit>()
                          .updateStatus(
                        orderIds: [
                          widget.shipment.id,
                        ],
                        statusId: ShipmentStatusApi.statusDeliveryFailed,
                        notes: notes,
                      );
                      if (!context.mounted) return;
                      if (!success) {
                        final state = context.read<ShipmentStatusCubit>().state;
                        showLocalMessage(
                          context,
                          state.locationUnavailable
                              ? tr(
                                  context,
                                  AppLocaleKey.shipmentStatusLocationRequired,
                                )
                              : state.errorMessage ??
                                  tr(
                                    context,
                                    AppLocaleKey.shipmentStatusUpdateFailed,
                                  ),
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
                        context
                                .read<ShipmentStatusCubit>()
                                .state
                                .successMessage ??
                            tr(context, AppLocaleKey.failureSaved),
                      );
                      Navigator.pop(context, true);
                    }),
        ]),
      );
}
