import 'package:flutter/material.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';
import '../../domain/shipment.dart';
import '../widgets/shipment_list.dart';
import 'all_shipments_view.dart';
import 'pending_shipments_view.dart';

/// Figma 11:78 and 11:131 — filters react to live shipment state and search.
class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});
  @override State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  int selectedFilter = 0;
  String search = '';

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final visible = state.shipments.where((shipment) {
      final matchesStatus = selectedFilter == 0 ||
        (selectedFilter == 1 && shipment.status == ShipmentStatus.pending) ||
        (selectedFilter == 2 && shipment.status == ShipmentStatus.delivered);
      final searchFields = '${shipment.id} ${shipment.customerAr} ${shipment.customerEn} '
        '${shipment.addressAr} ${shipment.addressEn}'.toLowerCase();
      return matchesStatus && searchFields.contains(search.toLowerCase());
    }).toList();

    return Scaffold(appBar: AppBar(title: Text(tr(context, 'shipments'))),
      body: PageBody(children: [
        TextField(onChanged: (value) => setState(() => search = value.trim()),
          decoration: InputDecoration(prefixIcon: const Icon(Icons.search),
            hintText: tr(context, 'searchShipments'))),
        const SizedBox(height: 14),
        Row(children: List.generate(3, (index) => Expanded(child: Padding(
          padding: const EdgeInsetsDirectional.only(end: 7),
          child: ChoiceChip(
            label: SizedBox(width: double.infinity, child: Text(
              tr(context, ['all', 'pendingTab', 'completedTab'][index]), textAlign: TextAlign.center)),
            selected: selectedFilter == index, selectedColor: AppColors.navy,
            labelStyle: TextStyle(color: selectedFilter == index ? Colors.white : AppColors.navy),
            onSelected: (_) => setState(() => selectedFilter = index),
          ),
        )))),
        const SizedBox(height: 10),
        Text('${visible.length} ${tr(context, 'shipmentCount')}',
          style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 8),
        if (selectedFilter == 0) AllShipmentsView(shipments: visible),
        if (selectedFilter == 1) PendingShipmentsView(shipments: visible),
        if (selectedFilter == 2) ShipmentList(shipments: visible),
      ]),
    );
  }
}
