import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/core/theme.dart';
import 'package:futureexpressapp/core/widgets.dart';
import 'package:futureexpressapp/features/shipments/data/repositories/shipments_repository.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';
import 'package:latlong2/latlong.dart';

class OrdersMapScreen extends StatefulWidget {
  const OrdersMapScreen({super.key, this.repository});

  final ShipmentsRepository? repository;

  @override
  State<OrdersMapScreen> createState() => _OrdersMapScreenState();
}

class _OrdersMapScreenState extends State<OrdersMapScreen> {
  static const _defaultCenter = LatLng(24.7136, 46.6753);

  final MapController _mapController = MapController();
  List<Shipment> _shipments = const [];
  Shipment? _selectedShipment;
  String? _error;
  bool _isLoading = true;
  bool _hasPositionedCamera = false;

  ShipmentsRepository get _repository =>
      widget.repository ?? sl<ShipmentsRepository>();

  List<Shipment> get _mappedShipments => _shipments.where((shipment) {
        final latitude = shipment.latitude;
        final longitude = shipment.longitude;
        return latitude != null &&
            longitude != null &&
            latitude.isFinite &&
            longitude.isFinite &&
            latitude >= -90 &&
            latitude <= 90 &&
            longitude >= -180 &&
            longitude <= 180;
      }).toList(growable: false);

  @override
  void initState() {
    super.initState();
    _loadShipments();
  }

  Future<void> _loadShipments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final shipments = <Shipment>[];
    var pageNumber = 1;
    try {
      while (true) {
        final result = await _repository.getShipments(page: pageNumber);
        if (!mounted) return;
        final failure = result.fold<String?>(
          (failure) => failure.errMessage,
          (_) => null,
        );
        if (failure != null) {
          setState(() {
            _error = failure;
            _isLoading = false;
          });
          return;
        }
        final page = result.fold<ShipmentPage?>((_) => null, (value) => value);
        if (page == null) {
          setState(() {
            _error = tr(context, AppLocaleKey.mapCouldNotLoad);
            _isLoading = false;
          });
          return;
        }
        shipments.addAll(page.shipments);
        if (page.currentPage >= page.lastPage) break;
        pageNumber = page.currentPage + 1;
      }

      setState(() {
        _shipments = List.unmodifiable(shipments);
        _isLoading = false;
      });
      _positionCamera();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _positionCamera() {
    if (_hasPositionedCamera) return;
    final points = _mappedShipments
        .map((shipment) => LatLng(shipment.latitude!, shipment.longitude!))
        .toList(growable: false);
    if (points.isEmpty) return;

    _hasPositionedCamera = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (points.length == 1) {
        _mapController.move(points.single, 13);
      } else {
        _mapController.fitCamera(
          CameraFit.coordinates(
            coordinates: points,
            padding: const EdgeInsets.all(64),
            maxZoom: 14,
          ),
        );
      }
    });
  }

  Color _statusColor(Shipment shipment) => switch (shipment.status) {
        ShipmentStatus.inTransit => AppColors.navy,
        ShipmentStatus.delivered => AppColors.green,
        ShipmentStatus.failed => AppColors.red,
        ShipmentStatus.other => AppColors.muted,
      };

  IconData _statusIcon(Shipment shipment) => switch (shipment.status) {
        ShipmentStatus.inTransit => Icons.local_shipping_outlined,
        ShipmentStatus.delivered => Icons.check,
        ShipmentStatus.failed => Icons.warning_amber_rounded,
        ShipmentStatus.other => Icons.inventory_2_outlined,
      };

  String _statusLabel(BuildContext context, Shipment shipment) =>
      switch (shipment.status) {
        ShipmentStatus.inTransit => tr(context, AppLocaleKey.statusInTransit),
        ShipmentStatus.delivered => tr(context, AppLocaleKey.statusDelivered),
        ShipmentStatus.failed => tr(context, AppLocaleKey.statusDeliveryFailed),
        ShipmentStatus.other =>
          shipment.statusLabel ?? tr(context, AppLocaleKey.other),
      };

  @override
  Widget build(BuildContext context) {
    final mapped = _mappedShipments;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, AppLocaleKey.ordersMap)),
        actions: [
          IconButton(
            tooltip: tr(context, AppLocaleKey.retry),
            onPressed: _isLoading ? null : _loadShipments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 5,
              onTap: _clearSelection,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.future.express.v3',
              ),
              MarkerLayer(
                markers: [
                  for (final shipment in mapped)
                    Marker(
                      point: LatLng(shipment.latitude!, shipment.longitude!),
                      width: 52,
                      height: 62,
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () => setState(
                          () => _selectedShipment = shipment,
                        ),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _statusColor(shipment),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x40000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _statusIcon(shipment),
                            color: AppColors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              RichAttributionWidget(
                attributions: const [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: _MapLegend(
              counts: {
                for (final status in [
                  ShipmentStatus.inTransit,
                  ShipmentStatus.delivered,
                  ShipmentStatus.failed,
                  ShipmentStatus.other,
                ])
                  status: mapped
                      .where((shipment) => shipment.status == status)
                      .length,
              },
              colorForStatus: (status) => switch (status) {
                ShipmentStatus.inTransit => AppColors.navy,
                ShipmentStatus.delivered => AppColors.green,
                ShipmentStatus.failed => AppColors.red,
                ShipmentStatus.other => AppColors.muted,
              },
            ),
          ),
          if (_isLoading)
            const Positioned(
              top: 76,
              left: 0,
              right: 0,
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_error != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: SurfaceCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!),
                    TextButton(
                      onPressed: _loadShipments,
                      child: Text(tr(context, AppLocaleKey.retry)),
                    ),
                  ],
                ),
              ),
            )
          else if (!_isLoading && mapped.isEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: SurfaceCard(
                child: Text(
                  tr(context, AppLocaleKey.noOrdersWithCoordinates),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (_selectedShipment case final shipment?)
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: SurfaceCard(
                child: Row(
                  children: [
                    Icon(
                      _statusIcon(shipment),
                      color: _statusColor(shipment),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '#${shipment.orderId ?? shipment.id}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(_statusLabel(context, shipment)),
                          if (shipment.clientAddress?.isNotEmpty ?? false)
                            Text(
                              shipment.clientAddress!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          else if (shipment.addressEn.isNotEmpty)
                            Text(
                              shipment.addressEn,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _selectedShipment = null),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _clearSelection(TapPosition _, LatLng __) {
    if (_selectedShipment != null) {
      setState(() => _selectedShipment = null);
    }
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend({
    required this.counts,
    required this.colorForStatus,
  });

  final Map<ShipmentStatus, int> counts;
  final Color Function(ShipmentStatus status) colorForStatus;

  @override
  Widget build(BuildContext context) => SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Wrap(
          alignment: WrapAlignment.spaceAround,
          spacing: 12,
          runSpacing: 8,
          children: [
            for (final status in [
              ShipmentStatus.inTransit,
              ShipmentStatus.delivered,
              ShipmentStatus.failed,
              ShipmentStatus.other,
            ])
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colorForStatus(status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    switch (status) {
                      ShipmentStatus.inTransit =>
                        tr(context, AppLocaleKey.statusInTransit),
                      ShipmentStatus.delivered =>
                        tr(context, AppLocaleKey.statusDelivered),
                      ShipmentStatus.failed =>
                        tr(context, AppLocaleKey.statusDeliveryFailed),
                      ShipmentStatus.other => tr(context, AppLocaleKey.other),
                    },
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 3),
                  Text('${counts[status] ?? 0}'),
                ],
              ),
          ],
        ),
      );
}
