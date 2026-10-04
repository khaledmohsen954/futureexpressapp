import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:futureexpressapp/core/assets/app_images.dart';
import 'package:futureexpressapp/core/routes/routes_name.dart';
import 'package:futureexpressapp/core/theme/app_colors.dart';
import 'package:futureexpressapp/core/utils/navigator_methods.dart';
import 'package:futureexpressapp/features/home/data/models/home_summary.dart';
import 'package:futureexpressapp/features/home/presentation/widgets/home_card.dart';
import 'package:futureexpressapp/features/shipments/presentation/screens/orders_map_screen.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../shipments/domain/shipment.dart';

class HomeCardStatusList extends StatelessWidget {
  const HomeCardStatusList({
    super.key,
    required this.state,
    required this.onTab,
    this.summary,
    this.useSummary = false,
  });

  final AppState state;
  final ValueChanged<int> onTab;
  final HomeSummary? summary;
  final bool useSummary;

  String _value(int? apiValue, int fallback) =>
      useSummary ? apiValue?.toString() ?? '—' : '$fallback';

  String _collectionValue() => useSummary
      ? summary?.todayCollected.toString() ?? '—'
      : '${state.totalCollected}';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          Expanded(
              child: HomeCard(
                  label: tr(context, AppLocaleKey.todayShipments),
                  value:
                      _value(summary?.todayShipments, state.shipments.length),
                  icon: Icons.inventory_2_outlined,
                  onTap: () => onTab(1))),
          const SizedBox(width: 10),
          Expanded(
              child: HomeCard(
                  label: tr(context, AppLocaleKey.delivered),
                  value: _value(
                    summary?.deliveredShipments,
                    state.count(ShipmentStatus.delivered),
                  ),
                  icon: Icons.check_circle_outline,
                  onTap: () => onTab(1))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: HomeCard(
                  label: tr(context, AppLocaleKey.inTransit),
                  value: _value(
                    summary?.inDeliveryShipments,
                    state.count(ShipmentStatus.inTransit),
                  ),
                  icon: Icons.local_shipping_outlined,
                  onTap: () => onTab(1))),
          const SizedBox(width: 10),
          Expanded(
              child: HomeCard(
                  label: tr(context, AppLocaleKey.todayCollection),
                  value: _collectionValue(),
                  icon: Icons.payments_outlined,
                  iconWidget: SvgPicture.asset(
                    AppImages.saudiRiyal,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      AppColor.whiteColor(context),
                      BlendMode.srcIn,
                    ),
                  ),
                  onTap: () => onTab(3))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: HomeCard(
                  label: tr(context, AppLocaleKey.pickup),
                  value: "",
                  icon: Icons.inventory_2_sharp,
                  onTap: () => NavigatorMethods.pushNamed(
                        context,
                        RoutesName.pickupScreen,
                      ))),
          const SizedBox(width: 10),
          Expanded(
              child: HomeCard(
                  label: tr(context, AppLocaleKey.showOnMap),
                  value: "",
                  icon: Icons.location_on_sharp,
                  onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const OrdersMapScreen(),
                        ),
                      ))),
        ]),
      ],
    );
  }
}

/// Single dashboard metric tile with its destination action.
