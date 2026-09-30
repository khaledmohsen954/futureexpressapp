import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:futureexpressapp/core/assets/app_images.dart';
import 'package:futureexpressapp/features/home/presentation/widgets/home_card.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../shipments/domain/shipment.dart';

class HomeCardStatusList extends StatelessWidget {
  const HomeCardStatusList({
    super.key,
    required this.state,
    required this.onTab,
  });

  final AppState state;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          Expanded(
              child: HomeCard(
                  label: tr(context, AppLocaleKey.todayShipments),
                  value: '${state.shipments.length}',
                  icon: Icons.inventory_2_outlined,
                  onTap: () => onTab(1))),
          const SizedBox(width: 10),
          Expanded(
              child: HomeCard(
                  label: tr(context, AppLocaleKey.delivered),
                  value: '${state.count(ShipmentStatus.delivered)}',
                  icon: Icons.check_circle_outline,
                  onTap: () => onTab(1))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: HomeCard(
                  label: tr(context, AppLocaleKey.inTransit),
                  value: '${state.count(ShipmentStatus.inTransit)}',
                  icon: Icons.local_shipping_outlined,
                  onTap: () => onTab(1))),
          const SizedBox(width: 10),
          Expanded(
              child: HomeCard(
                  label: tr(context, AppLocaleKey.todayCollection),
                  value: '${state.totalCollected}',
                  icon: Icons.payments_outlined,
                  iconWidget: SvgPicture.asset(AppImages.saudiRiyal, width: 35, height: 35),
                  onTap: () => onTab(3))),
        ]),
      ],
    );
  }
}

/// Single dashboard metric tile with its destination action.
