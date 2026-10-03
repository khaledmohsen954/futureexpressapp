import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routes/routes_name.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/navigator_methods.dart';
import '../../../../core/widgets.dart';
import '../../domain/shipment.dart';
import '../cubit/shipments_cubit.dart';

/// Figma 11:184 — local delivery and failure actions for expanded shipments.
class ShipmentDetails extends StatelessWidget {
  const ShipmentDetails({super.key, required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context) => Column(children: [
        const Divider(),
        _DetailRow(Icons.phone_outlined, shipment.customerPhone),
        const SizedBox(height: 8),
        _DetailRow(Icons.notes_outlined, tr(context, AppLocaleKey.customerNote)),
        const SizedBox(height: 8),
        _DetailRow(
            Icons.payments_outlined,
            tr(
                context,
                shipment.paymentMethod == PaymentMethod.cash
                    ? AppLocaleKey.cashCollection
                    : AppLocaleKey.onlineCollection)),
        if (shipment.status == ShipmentStatus.inTransit) ...[
          const SizedBox(height: 12),
          ActionButton(
              label: tr(context, AppLocaleKey.markDelivered),
              icon: Icons.check_circle_outline,
              color: AppColors.green,
              onPressed: () {
                NavigatorMethods.pushNamed(
                  context,
                  RoutesName.shipmentDetailsScreen,
                  arguments: shipment,
                ).then((updated) {
                  if (updated == true && context.mounted) {
                    context.read<ShipmentsCubit>().loadFirstPage();
                  }
                });
              }),
        ],
        if (shipment.status == ShipmentStatus.inTransit) ...[
          const SizedBox(height: 10),
          ActionButton(
            label: tr(context, AppLocaleKey.deliveryFailure),
            icon: Icons.report_problem_outlined,
            outlined: true,
            onPressed: () {
              NavigatorMethods.pushNamed(
                context,
                RoutesName.deliveryFailureScreen,
                arguments: shipment,
              ).then((updated) {
                if (updated == true && context.mounted) {
                  context.read<ShipmentsCubit>().loadFirstPage();
                }
              });
            },
          ),
        ],
        if (AppScope.of(context).failureReasons.containsKey(shipment.id))
          Text(
              '${tr(context, AppScope.of(context).failureReasons[shipment.id]!)} ${AppScope.of(context).failureNotes[shipment.id] ?? ''}',
              style: Theme.of(context).textTheme.bodySmall),
      ]);
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 19, color: AppColors.muted),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ]);
}
