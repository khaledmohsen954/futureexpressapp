import 'package:flutter/material.dart';
import 'package:futureexpressapp/features/shipments/presentation/widgets/shipment_list.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';
import '../../domain/shipment.dart';

/// Figma 11:78 and 11:131 — filters react to live shipment state and search.
class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});
  @override
  State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  int selectedFilter = 0;
  String search = '';
  final filterKeys = List<GlobalKey>.generate(4, (_) => GlobalKey());

  void _selectFilter(int index) {
    setState(() => selectedFilter = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final filterContext = filterKeys[index].currentContext;
      if (filterContext != null) {
        Scrollable.ensureVisible(
          filterContext,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    const filterStatuses = <ShipmentStatus>[
      ShipmentStatus.pending,
      ShipmentStatus.inTransit,
      ShipmentStatus.delivered,
      ShipmentStatus.failed,
    ];
    const filterLabels = [
      AppLocaleKey.statusReceived,
      AppLocaleKey.statusInTransit,
      AppLocaleKey.statusDelivered,
      AppLocaleKey.statusDeliveryFailed,
    ];
    final selectedStatus = filterStatuses[selectedFilter];
    final visible = state.shipments.where((shipment) {
      final matchesStatus = shipment.status == selectedStatus;
      final searchFields =
          '${shipment.id} ${shipment.customerAr} ${shipment.customerEn} '
                  '${shipment.addressAr} ${shipment.addressEn}'
              .toLowerCase();
      return matchesStatus && searchFields.contains(search.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, AppLocaleKey.shipments))),
      body: PageBody(children: [
        TextField(
            onChanged: (value) => setState(() => search = value.trim()),
            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: tr(context, AppLocaleKey.searchShipments))),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              filterLabels.length,
              (index) => Padding(
                key: filterKeys[index],
                padding: const EdgeInsetsDirectional.only(end: 7),
                child: ChoiceChip(
                  label: Text(tr(context, filterLabels[index])),
                  selected: selectedFilter == index,
                  selectedColor: AppColors.navy,
                  labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selectedFilter == index
                          ? AppColors.onDark
                          : AppColors.navy),
                  onSelected: (_) => _selectFilter(index),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text('${visible.length} ${tr(context, AppLocaleKey.shipmentCount)}',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        ShipmentList(shipments: visible),
      ]),
    );
  }
}
