import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'data/sample_shipments.dart';
import 'models/shipment.dart';
import 'widgets/shipment_list.dart';
import 'all_shipments_view.dart';
import 'pending_shipments_view.dart';

/// Figma screens 03–04: all and pending shipment views with search and status filters.
class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});

  @override
  State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  int selectedFilter = 0;
  String search = '';

  @override
  Widget build(BuildContext context) {
    // The selected filter changes the visible local list without a network request.
    final visible = sampleShipments.where((shipment) {
      final matchesStatus = selectedFilter == 0 ||
          (selectedFilter == 1 && shipment.status == ShipmentStatus.pending) ||
          (selectedFilter == 2 && shipment.status == ShipmentStatus.delivered);
      final matchesSearch = '${shipment.id} ${shipment.customer} ${shipment.address}'
          .contains(search);
      return matchesStatus && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('الشحنات')),
      body: PageBody(children: [
        TextField(
          onChanged: (value) => setState(() => search = value.trim()),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search), hintText: 'ابحث برقم الشحنة أو العميل'),
        ),
        const SizedBox(height: 14),
        Row(children: List.generate(3, (index) => Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 7),
            child: ChoiceChip(
              label: SizedBox(width: double.infinity,
                child: Text(['الكل', 'المعلقة', 'المكتملة'][index], textAlign: TextAlign.center)),
              selected: selectedFilter == index,
              selectedColor: AppColors.navy,
              labelStyle: TextStyle(color: selectedFilter == index ? Colors.white : AppColors.navy),
              onSelected: (_) => setState(() => selectedFilter = index),
            ),
          ),
        ))),
        const SizedBox(height: 10),
        Text('${visible.length} شحنات', style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 8),
        // Each Figma shipment state has a dedicated UI file.
        if (selectedFilter == 0) AllShipmentsView(shipments: visible),
        if (selectedFilter == 1) PendingShipmentsView(shipments: visible),
        if (selectedFilter == 2) ShipmentList(shipments: visible),
      ]),
    );
  }
}
