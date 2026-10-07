import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/features/shipments/data/repositories/daily_shipment_sequence_store.dart';
import 'package:futureexpressapp/features/shipments/data/repositories/shipments_repository.dart';
import 'package:futureexpressapp/features/shipments/presentation/cubit/shipments_cubit.dart';
import 'package:futureexpressapp/features/shipments/presentation/widgets/shipment_list.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';
import '../../domain/shipment.dart';

/// Figma 11:78 and 11:131 — filters react to live shipment state and search.
class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({
    super.key,
    this.repository,
    this.sequenceStore,
  });

  final ShipmentsRepository? repository;
  final ShipmentSequenceStore? sequenceStore;

  @override
  State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  String search = '';
  int selectedTabIndex = 0;
  int? selectedStatusFilterId;
  final tabKeys = List<GlobalKey>.generate(3, (_) => GlobalKey());

  static const _tabStatusIds = <int>[
    ShipmentStatusApi.statusInTransit,
    ShipmentStatusApi.statusDelivered,
    ShipmentStatusApi.statusDeliveryFailed,
  ];
  static const _tabLabels = <String>[
    AppLocaleKey.statusInTransit,
    AppLocaleKey.statusDelivered,
    AppLocaleKey.statusDeliveryFailed,
  ];

  void _selectTab(int index) {
    setState(() => selectedTabIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final filterContext = tabKeys[index].currentContext;
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

  // Future<void> _showStatusFilter(
  //   BuildContext context,
  //   List<ShipmentStatusFilter> statuses,
  // ) async {
  //   final cubit = context.read<ShipmentsCubit>();
  //   final supportedStatuses = statuses
  //       .where((status) => ShipmentStatusApi.supportedStatusIds.contains(status.id))
  //       .toList(growable: false);
  //   final selection = await showModalBottomSheet<int>(
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (sheetContext) => SafeArea(
  //       child: Padding(
  //         padding: const EdgeInsets.only(top: 12, bottom: 12),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
  //               child: Row(
  //                 children: [
  //                   Expanded(
  //                     child: Text(
  //                       tr(sheetContext, AppLocaleKey.filterStatus),
  //                       style: Theme.of(sheetContext).textTheme.titleLarge,
  //                     ),
  //                   ),
  //                   TextButton(
  //                     onPressed: () => Navigator.pop(sheetContext, 0),
  //                     child: Text(
  //                       tr(sheetContext, AppLocaleKey.clearStatusFilter),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Flexible(
  //               child: ListView.builder(
  //                 shrinkWrap: true,
  //                 itemCount: supportedStatuses.length,
  //                 itemBuilder: (context, index) {
  //                   final status = supportedStatuses[index];
  //                   final selected = status.id == selectedStatusFilterId;
  //                   return ListTile(
  //                     leading: Icon(
  //                       selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
  //                       color: selected ? AppColors.red : AppColors.muted,
  //                     ),
  //                     title: Row(
  //                       children: [
  //                         Text(status.id.toString()),
  //                         Text(status.localizedTitle(Localizations.localeOf(context).languageCode)),
  //                       ],
  //                     ),
  //                     selected: selected,
  //                     onTap: () => Navigator.pop(sheetContext, status.id),
  //                   );
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  //   if (!mounted || selection == null) return;
  //   final statusId = selection == 0 ? null : selection;
  //   setState(() => selectedStatusFilterId = statusId);
  //   cubit.setStatusFilter(statusId);
  // }

  // void _clearStatusFilter(BuildContext context) {
  //   setState(() => selectedStatusFilterId = null);
  //   context.read<ShipmentsCubit>().setStatusFilter(null);
  // }

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ShipmentsCubit(
          repository: widget.repository ?? sl<ShipmentsRepository>(),
        )
          // ..loadStatuses()
          ..loadFirstPage(),
        child: Builder(builder: _buildContent),
      );

  Widget _buildContent(BuildContext context) {
    final cubit = context.watch<ShipmentsCubit>();
    final shipmentsState = cubit.state;
    // final selectedStatuses = shipmentsState.availableStatuses
    //     .where((status) =>
    //         status.id == selectedStatusFilterId &&
    //         ShipmentStatusApi.supportedStatusIds.contains(status.id))
    //     .toList(growable: false);
    // final selectedStatus = selectedStatuses.isEmpty ? null : selectedStatuses.first;
    final tabStatusId = _tabStatusIds[selectedTabIndex];
    final tabCounts =
        List<int>.filled(_tabStatusIds.length, 0, growable: false);
    for (final shipment in shipmentsState.shipments) {
      final statusId = shipment.apiStatusId;
      if (statusId != null) {
        final statusIndex = _tabStatusIds.indexOf(statusId);
        if (statusIndex != -1) {
          tabCounts[statusIndex]++;
        }
      }
    }
    final matchingTab = shipmentsState.shipments.where((shipment) {
      final matchesSupportedStatus =
          ShipmentStatusApi.supportedStatusIds.contains(shipment.apiStatusId);
      final matchesTab = shipment.apiStatusId == tabStatusId;
      return matchesSupportedStatus && matchesTab;
    }).toList();
    final filtered = matchingTab.where((shipment) {
      final searchFields =
          '${shipment.id} ${shipment.orderId ?? ''} ${shipment.store ?? ''} '
                  '${shipment.customerAr} ${shipment.customerEn} '
                  '${shipment.addressAr} ${shipment.addressEn} '
                  '${shipment.customerPhone}'
              .toLowerCase();
      return searchFields.contains(search.toLowerCase());
    }).toList();
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
        child: RefreshIndicator(
          onRefresh: cubit.loadFirstPage,
          child: PageBody(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (shipmentsState.areStatusesLoading)
                const LinearProgressIndicator(),
              if (shipmentsState.statusesError != null)
                Row(
                  children: [
                    Expanded(child: Text(shipmentsState.statusesError!)),
                    TextButton(
                      onPressed: cubit.retryStatuses,
                      child: Text(tr(context, AppLocaleKey.retry)),
                    ),
                  ],
                ),
              // if (shipmentsState.availableStatuses.isNotEmpty)
              //   Wrap(
              //     spacing: 8,
              //     runSpacing: 8,
              //     crossAxisAlignment: WrapCrossAlignment.center,
              //     children: [
              //       OutlinedButton.icon(
              //         onPressed: () => _showStatusFilter(
              //           context,
              //           shipmentsState.availableStatuses,
              //         ),
              //         icon: const Icon(Icons.filter_list),
              //         label: Text(tr(context, AppLocaleKey.filterStatus)),
              //       ),
              //       if (selectedStatus != null)
              //         InputChip(
              //           label: Text(selectedStatus.localizedTitle(
              //               Localizations.localeOf(context).languageCode)),
              //           onDeleted: () => _clearStatusFilter(context),
              //         ),
              //     ],
              //   ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_tabLabels.length, (index) {
                    final selected = selectedTabIndex == index;
                    final count =
                        shipmentsState.statusCounts[_tabStatusIds[index]] ??
                            tabCounts[index];
                    return Padding(
                      key: tabKeys[index],
                      padding: const EdgeInsetsDirectional.only(end: 7),
                      child: ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(tr(context, _tabLabels[index])),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.onDark.withValues(alpha: 0.2)
                                    : AppColors.navy.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                count.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: selected
                                          ? AppColors.onDark
                                          : AppColors.navy,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        selected: selected,
                        selectedColor: AppColors.navy,
                        labelStyle: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              color:
                                  selected ? AppColors.onDark : AppColors.navy,
                            ),
                        onSelected: (_) => _selectTab(index),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                  onChanged: (value) => setState(() => search = value.trim()),
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: tr(context, AppLocaleKey.searchShipments))),
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
                Text(
                    '${visible.length} ${tr(context, AppLocaleKey.shipmentCount)}',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                ShipmentList(
                  shipments: visible,
                  numberInTransitShipments: selectedTabIndex == 0,
                  sequenceSource: selectedTabIndex == 0 ? matchingTab : null,
                  sequenceStore: widget.sequenceStore,
                ),
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
            ],
          ),
        ),
      ),
    );
  }
}
