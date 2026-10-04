import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futureexpressapp/core/routes/routes_name.dart';
import 'package:futureexpressapp/core/utils/navigator_methods.dart';
import 'package:futureexpressapp/features/shipments/presentation/widgets/shipment_details.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';
import '../../domain/shipment.dart';
import '../cubit/shipments_cubit.dart';

/// Figma 11:184 — expandable card stays in sync with shipment changes.
class ShipmentCard extends StatefulWidget {
  const ShipmentCard({super.key, required this.shipment});
  final Shipment shipment;
  @override
  State<ShipmentCard> createState() => _ShipmentCardState();
}

class _ShipmentCardState extends State<ShipmentCard> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final shipment = widget.shipment;
    final english = AppScope.of(context).locale.languageCode == 'en';
    final amount = double.tryParse(shipment.amountLabel ?? '') ??
        shipment.amount.toDouble();
    final statusKey = switch (shipment.status) {
      // ShipmentStatus.pending => AppLocaleKey.pending,
      ShipmentStatus.inTransit => AppLocaleKey.inTransit,
      ShipmentStatus.delivered => AppLocaleKey.delivered,
      ShipmentStatus.failed => AppLocaleKey.deliveryFailure,
      ShipmentStatus.other => AppLocaleKey.other,
    };
    final statusLabel =
        (english ? shipment.statusLabel : shipment.statusLabelAr) ??
            shipment.statusLabel;
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: SurfaceCard(
          child: Column(children: [
        Row(children: [
          const Icon(Icons.inventory_2_outlined, color: AppColors.red),
          const SizedBox(width: 8),
          Text('#${shipment.orderId ?? shipment.id}',
              style: Theme.of(context).textTheme.labelLarge),
          const Spacer(),
          Flexible(
              child: Text(statusLabel ?? tr(context, statusKey),
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: shipment.status == ShipmentStatus.delivered
                          ? AppColors.green
                          : AppColors.red,
                      fontWeight: FontWeight.w700))),
        ]),
        const Divider(height: 23),
        _Info(Icons.person_outline,
            english ? shipment.customerEn : shipment.customerAr),
        const SizedBox(height: 8),
        _Info(Icons.location_on_outlined,
            english ? shipment.addressEn : shipment.addressAr),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.payments_outlined, size: 19, color: AppColors.muted),
          const SizedBox(width: 8),
          if (amount > 0) ...[
            Text(
              '${tr(context, AppLocaleKey.shipmentAmount)} : ',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            Money(amount, crossAxisAlignment: CrossAxisAlignment.end),
          ] else
            Text(
              tr(context, AppLocaleKey.fullyPaidOnline),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ]),
        const SizedBox(height: 10),
        InkWell(
            onTap: () {
              NavigatorMethods.pushNamed(
                      context, RoutesName.shipmentDetailsScreen,
                      arguments: shipment)
                  .then((updated) {
                if (updated == true && context.mounted) {
                  context.read<ShipmentsCubit>().loadFirstPage();
                }
              });

              // setState(() => expanded = !expanded);
            },
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(tr(context, AppLocaleKey.showDetails),
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: AppColors.red)),
              const Icon(Icons.chevron_right, color: AppColors.red),
            ])),
        if (expanded) ShipmentDetails(shipment: shipment),
      ])),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 19, color: AppColors.muted),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
      ]);
}
