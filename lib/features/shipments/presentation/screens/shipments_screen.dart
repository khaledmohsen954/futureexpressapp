import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/features/shipments/data/repositories/shipments_repository.dart';
import 'package:futureexpressapp/features/shipments/presentation/cubit/shipments_cubit.dart';
import 'package:futureexpressapp/features/shipments/presentation/widgets/shipment_list.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';
import '../../domain/shipment.dart';

/// Figma 11:78 and 11:131 — filters react to live shipment state and search.
class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key, this.repository});

  final ShipmentsRepository? repository;

  @override
  State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  int selectedFilter = 0;
  String search = '';
  final filterKeys = List<GlobalKey>.generate(5, (_) => GlobalKey());
  static const filterStatusIds = <int?>[
    null,
    ShipmentStatusApi.statusReceived,
    ShipmentStatusApi.statusInTransit,
    ShipmentStatusApi.statusDelivered,
    ShipmentStatusApi.statusDeliveryFailed,
  ];

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
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ShipmentsCubit(
          repository: widget.repository ?? sl<ShipmentsRepository>(),
        )..loadFirstPage(),
        child: Builder(builder: _buildContent),
      );

  Widget _buildContent(BuildContext context) {
    const filterLabels = [
      AppLocaleKey.all,
      AppLocaleKey.statusReceived,
      AppLocaleKey.statusInTransit,
      AppLocaleKey.statusDelivered,
      AppLocaleKey.statusDeliveryFailed,
    ];
    final shipmentsState = context.watch<ShipmentsCubit>().state;
    final selectedStatusId = filterStatusIds[selectedFilter];
    final filtered = shipmentsState.shipments.where((shipment) {
      final matchesStatus =
          selectedStatusId == null || shipment.apiStatusId == selectedStatusId;
      final searchFields =
          '${shipment.id} ${shipment.orderId ?? ''} ${shipment.store ?? ''} '
                  '${shipment.customerAr} ${shipment.customerEn} '
                  '${shipment.addressAr} ${shipment.addressEn} '
                  '${shipment.customerPhone}'
              .toLowerCase();
      return matchesStatus && searchFields.contains(search.toLowerCase());
    }).toList();
    if (selectedStatusId == null) {
      filtered.sort(
        (a, b) => (a.apiStatusId ?? a.status.apiId)
            .compareTo(b.apiStatusId ?? b.status.apiId),
      );
    }
    final visible = filtered;

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, AppLocaleKey.shipments))),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.depth == 0 &&
              notification.metrics.extentAfter < 250) {
            context.read<ShipmentsCubit>().loadNextPage();
          }
          return false;
        },
        child: PageBody(children: [
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
                    labelStyle: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(
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
          if (shipmentsState.status == ShipmentsStatus.loading)
            const Center(child: CircularProgressIndicator())
          else if (shipmentsState.status == ShipmentsStatus.failure)
            Center(
              child: Column(
                children: [
                  Text(shipmentsState.errorMessage ??
                      'Unable to load shipments.'),
                  TextButton(
                    onPressed: context.read<ShipmentsCubit>().loadFirstPage,
                    child: Text(tr(context, AppLocaleKey.retry)),
                  ),
                ],
              ),
            )
          else ...[
            Text('${visible.length} ${tr(context, AppLocaleKey.shipmentCount)}',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            ShipmentList(shipments: visible),
            if (shipmentsState.loadMoreError != null)
              Center(
                child: TextButton(
                  onPressed: context.read<ShipmentsCubit>().retryNextPage,
                  child: Text(tr(context, AppLocaleKey.retry)),
                ),
              )
            else if (shipmentsState.isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (shipmentsState.hasNextPage)
              Center(
                child: TextButton(
                  onPressed: context.read<ShipmentsCubit>().loadNextPage,
                  child: Text(tr(context, AppLocaleKey.loadMore)),
                ),
              ),
          ],
        ]),
      ),
    );
  }
}
