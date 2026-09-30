import 'package:flutter/material.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';

import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';

class HomeOrderCard extends StatelessWidget {
  const HomeOrderCard({
    super.key,
    required this.recent,
    required this.english,
  });

  final Shipment recent;
  final bool english;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
        child: Row(children: [
      const Icon(Icons.inventory_2_outlined, color: AppColors.red),
      const SizedBox(width: 12),
      Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('#${recent.id}', style: Theme.of(context).textTheme.labelLarge),
        Text(
            '${english ? recent.customerEn : recent.customerAr} • ${english ? recent.addressEn : recent.addressAr}',
            style: Theme.of(context).textTheme.bodySmall),
      ])),
      const Icon(Icons.chevron_left),
    ]));
  }
}
