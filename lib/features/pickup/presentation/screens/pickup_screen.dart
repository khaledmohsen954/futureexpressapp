import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/core/utils/common_methods.dart';
import 'package:futureexpressapp/core/widgets.dart';
import 'package:futureexpressapp/features/pickup/data/repositories/pickup_repository.dart';
import 'package:futureexpressapp/features/pickup/presentation/screens/pickup_capture_mixin.dart';
import 'package:futureexpressapp/features/pickup/presentation/screens/pickup_scan_mixin.dart';
import 'package:futureexpressapp/features/pickup/presentation/screens/pickup_submit_mixin.dart';
import 'package:futureexpressapp/features/pickup/presentation/screens/pickup_utils.dart';
import 'package:futureexpressapp/features/pickup/presentation/widgets/pickup_available_orders.dart';
import 'package:futureexpressapp/features/pickup/presentation/widgets/pickup_customer_order_card.dart';
import 'package:futureexpressapp/features/pickup/presentation/widgets/pickup_merchant_order_card.dart';
import 'package:futureexpressapp/features/pickup/presentation/widgets/pickup_source_segment.dart';
import 'package:futureexpressapp/features/pickup/presentation/screens/pickup_qr_scan_screen.dart';
import 'package:futureexpressapp/features/shipments/domain/shipment.dart';
import 'package:image_picker/image_picker.dart';

class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key, this.preScannedShipment});

  /// When non-null the order was already scanned (e.g. from [ScannerScreen])
  /// and should be added to the customer pickup list automatically.
  final Shipment? preScannedShipment;

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen>
    with PickupScanMixin, PickupCaptureMixin, PickupSubmitMixin {
  final ImagePicker _imagePicker = ImagePicker();
  final Map<PickupSource, List<ScannedPickupOrder>> _orders = {
    PickupSource.customer: [],
    PickupSource.merchant: [],
  };
  final Map<PickupSource, List<Shipment>> _availableOrders = {
    PickupSource.customer: [],
    PickupSource.merchant: [],
  };

  PickupSource _source = PickupSource.customer;
  bool _isBusy = false;
  bool _isLoadingOrders = false;
  String? _ordersError;

  List<ScannedPickupOrder> get _currentOrders => _orders[_source]!;
  List<Shipment> get _currentAvailableOrders {
    final scannedIds = _orders[_source]!.map((order) => order.id).toSet();
    return _availableOrders[_source]!
        .where((shipment) => !scannedIds.contains(pickupOrderId(shipment)))
        .toList(growable: false);
  }

  @override
  bool get isBusy => _isBusy;
  @override
  set isBusy(bool value) => _isBusy = value;

  @override
  PickupSource get source => _source;

  @override
  Map<PickupSource, List<ScannedPickupOrder>> get orders => _orders;

  @override
  List<ScannedPickupOrder> get currentOrders => _currentOrders;

  @override
  ImagePicker get imagePicker => _imagePicker;

  @override
  Future<void> Function(String orderId) get doCaptureConfirmationImage => _captureConfirmationImage;

  @override
  Future<void> Function(String orderId, File image) get doConfirmCustomerOrder =>
      _confirmCustomerOrder;

  @override
  Future<void> Function({bool showLoading}) get doLoadPickupOrders => _loadPickupOrders;

  @override
  void initState() {
    super.initState();
    debugPrint('PICKUP initState');
    unawaited(_loadPickupOrders());
    final preScanned = widget.preScannedShipment;
    if (preScanned != null) {
      _addPreScannedOrder(preScanned);
    }
  }

  void _addPreScannedOrder(Shipment shipment) {
    final orderId = pickupOrderId(shipment);
    final source = pickupSourceForShipment(shipment);
    _source = source;
    _orders[source]!.add(ScannedPickupOrder(id: orderId));
    if (source == PickupSource.customer) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) await _captureConfirmationImage(orderId);
      });
    }
  }

  Future<void> _loadPickupOrders({bool showLoading = true}) async {
    if (_isLoadingOrders) return;
    if (showLoading) {
      setState(() {
        _isLoadingOrders = true;
        _ordersError = null;
      });
    }
    final result = await sl<PickupRepository>().getDelegateReturnOrders();
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() {
          _isLoadingOrders = false;
          _ordersError = failure.errMessage;
        });
      },
      (shipments) {
        setState(() {
          _availableOrders[PickupSource.customer] = shipments
              .where((shipment) => shipment.apiStatusId == PickupSource.customer.statusId)
              .toList(growable: false);
          _availableOrders[PickupSource.merchant] = shipments
              .where((shipment) => shipment.apiStatusId == PickupSource.merchant.statusId)
              .toList(growable: false);
          _isLoadingOrders = false;
          _ordersError = null;
        });
      },
    );
  }

  Future<void> _captureConfirmationImage(String orderId) => captureConfirmationImage(orderId);

  Future<void> _confirmCustomerOrder(String orderId, File image) =>
      confirmCustomerOrder(orderId, image);

  Future<void> _scanMerchantShipment() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final scannedCode = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const PickupQrScanScreen()),
      );
      if (!mounted || scannedCode == null) return;
      final code = scannedCode.trim();
      debugPrint('MERCHANT SCAN code=$code available=${_currentAvailableOrders.map(pickupOrderCodes).toList()}');
      final normalizedCode = code.toUpperCase();
      Shipment? matched;
      for (final shipment in _currentAvailableOrders) {
        if (pickupOrderCodes(shipment).any(
          (value) => value.trim().toUpperCase() == normalizedCode,
        )) {
          matched = shipment;
          break;
        }
      }

      // Server scan endpoint currently returns 500 for arbitrary QR codes, so
      // keep flow purely local and report the locally known codes instead.


      if (matched == null) {
        final availableCodes = _currentAvailableOrders
            .map((shipment) => pickupOrderCodes(shipment).join('/'))
            .join(', ');
        debugPrint('MERCHANT SCAN no-match code=$code available=[$availableCodes]');
        if (mounted) {
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('لا يوجد لديك شحنه بهذا الرقم'),
              content: SelectableText('code=$code\navailable=[$availableCodes]'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(tr(context, AppLocaleKey.confirm)),
                ),
              ],
            ),
          );
        }
        return;
      }
      final orderId = pickupOrderId(matched);
      final isDuplicate =
          _orders[PickupSource.merchant]!.any((order) => order.id == orderId);
      if (isDuplicate) {
        if (mounted) {
          showLocalMessage(context, tr(context, AppLocaleKey.orderAlreadyScanned));
        }
        return;
      }
      setState(() {
        _orders[PickupSource.merchant]!.add(ScannedPickupOrder(id: orderId));
      });
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  void dispose() {
    final files =
        _orders.values.expand((orders) => orders).map((order) => order.confirmationImage).toList();
    unawaited(CommonMethods.cleanupStagingFiles(files));
    debugPrint('PICKUP dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, AppLocaleKey.pickup))),
      body: PageBody(
        children: [
          PickupSourceSegment(
            selected: _source,
            onSelectionChanged: (source) => setState(() => _source = source),
            enabled: !_isBusy,
          ),
          const SizedBox(height: 18),
          if (_source == PickupSource.merchant) ...[
            FilledButton.icon(
              onPressed: _isBusy ? null : () => unawaited(_scanMerchantShipment()),
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(tr(context, AppLocaleKey.scanQr)),
            ),
            const SizedBox(height: 12),
          ],
          PickupAvailableOrders(
            shipments: _currentAvailableOrders,
            isLoading: _isLoadingOrders,
            error: _ordersError,
            onRetry: () => unawaited(doLoadPickupOrders()),
            onScan: (shipment) => unawaited(scanShipment(shipment)),
            isBusy: _isBusy,
          ),
          if (_isBusy) ...[
            const SizedBox(height: 12),
            const SurfaceCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CustomLoading(size: 32),
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          if (_source == PickupSource.customer) ...[
            Text(
              tr(context, AppLocaleKey.shipmentNumber),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_currentOrders.isEmpty)
              SurfaceCard(
                child: Center(
                  child: Text(tr(context, AppLocaleKey.noPickupOrders)),
                ),
              )
            else
              PickupCustomerOrderCard(
                order: _currentOrders.single,
                onRetake: () => unawaited(retakeConfirmationImage(_currentOrders.single.id)),
                onRemove: () => unawaited(removeOrder(_currentOrders.single.id)),
                isBusy: _isBusy,
              ),
          ] else ...[
            Text(
              '${tr(context, AppLocaleKey.scannedOrders)} (${_currentOrders.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_currentOrders.isEmpty)
              SurfaceCard(
                child: Center(
                  child: Text(tr(context, AppLocaleKey.noPickupOrders)),
                ),
              )
            else
              for (var index = 0; index < _currentOrders.length; index++)
                PickupMerchantOrderCard(
                  order: _currentOrders[index],
                  index: index,
                  onRemove: () => unawaited(removeOrder(_currentOrders[index].id)),
                  isBusy: _isBusy,
                ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isBusy || _currentOrders.isEmpty ? null : submitPickup,
            icon: const Icon(Icons.check),
            label: Text(tr(context, AppLocaleKey.submitPickup)),
          ),
        ],
      ),
    );
  }
}
