import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futureexpressapp/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/core/utils/common_methods.dart';
import 'package:futureexpressapp/core/widgets.dart';
import 'package:futureexpressapp/features/pickup/data/repositories/pickup_repository.dart';
import 'package:futureexpressapp/features/scanner/presentation/widgets/qr_code_scanner.dart';
import 'package:image_picker/image_picker.dart';

enum _PickupSource { customer, merchant }

class _ScannedPickupOrder {
  const _ScannedPickupOrder({required this.id, this.confirmationImage});

  final String id;
  final File? confirmationImage;

  _ScannedPickupOrder withImage(File image) =>
      _ScannedPickupOrder(id: id, confirmationImage: image);
}

class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key});

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final GlobalKey<QrCodeScannerState> _scannerKey =
      GlobalKey<QrCodeScannerState>();
  final ImagePicker _imagePicker = ImagePicker();
  final Map<_PickupSource, List<_ScannedPickupOrder>> _orders = {
    _PickupSource.customer: [],
    _PickupSource.merchant: [],
  };

  _PickupSource _source = _PickupSource.customer;
  bool _isBusy = false;
  bool _customerScanComplete = false;
  bool _merchantWaitingForNextScan = false;

  List<_ScannedPickupOrder> get _currentOrders => _orders[_source]!;
  bool get _showScanner => switch (_source) {
        _PickupSource.customer => !_customerScanComplete,
        _PickupSource.merchant => !_merchantWaitingForNextScan,
      };

  Future<void> _onScan(String code) async {
    if (_isBusy) return;
    final scanSource = _source;
    setState(() => _isBusy = true);
    try {
      final orders = _orders[scanSource]!;
      final orderId = code.trim();
      final isDuplicate = orders.any((order) => order.id == orderId);
      if (isDuplicate) {
        showLocalMessage(
            context, tr(context, AppLocaleKey.orderAlreadyScanned));
        if (scanSource == _PickupSource.merchant) {
          setState(() => _merchantWaitingForNextScan = true);
        }
      } else {
        setState(() {
          orders.add(_ScannedPickupOrder(id: orderId));
          if (scanSource == _PickupSource.customer) {
            _customerScanComplete = true;
          } else {
            _merchantWaitingForNextScan = true;
          }
        });
        if (scanSource == _PickupSource.customer) {
          await WidgetsBinding.instance.endOfFrame;
          await _captureConfirmationImage(orderId);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _captureConfirmationImage(String orderId) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (!mounted || image == null) return;

      final compressed = await CommonMethods.compressImage(File(image.path));
      if (!mounted) {
        await CommonMethods.cleanupStagingFiles([compressed]);
        return;
      }
      final orders = _currentOrders;
      final index = orders.indexWhere((order) => order.id == orderId);
      if (index == -1) {
        await CommonMethods.cleanupStagingFiles([compressed]);
        return;
      }
      final previousImage = orders[index].confirmationImage;
      setState(() {
        orders[index] = orders[index].withImage(compressed);
      });
      if (previousImage != null) {
        await CommonMethods.cleanupStagingFiles([previousImage]);
      }
    } on PlatformException catch (error) {
      if (mounted) {
        showLocalMessage(
          context,
          error.message ?? tr(context, AppLocaleKey.confirmationPhotoRequired),
        );
      }
    } catch (error) {
      if (mounted) showLocalMessage(context, error.toString());
    }
  }

  Future<void> _retakeConfirmationImage(String orderId) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await _captureConfirmationImage(orderId);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _scanAnotherMerchantOrder() {
    if (_isBusy || _source != _PickupSource.merchant) return;
    setState(() => _merchantWaitingForNextScan = false);
  }

  Future<void> _retryCustomerScan() async {
    if (_isBusy || _source != _PickupSource.customer) return;
    final images = _orders[_PickupSource.customer]!
        .map((order) => order.confirmationImage)
        .toList();
    setState(() {
      _orders[_PickupSource.customer]!.clear();
      _customerScanComplete = false;
    });
    await CommonMethods.cleanupStagingFiles(images);
  }

  Future<void> _removeOrder(String orderId) async {
    final index = _currentOrders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;
    final image = _currentOrders[index].confirmationImage;
    setState(() => _currentOrders.removeAt(index));
    if (image != null) await CommonMethods.cleanupStagingFiles([image]);
  }

  Future<void> _submitPickup() async {
    if (_isBusy || _currentOrders.isEmpty) return;
    final orders = List<_ScannedPickupOrder>.of(_currentOrders);
    if (_source == _PickupSource.customer &&
        (orders.length != 1 || orders.single.confirmationImage == null)) {
      showLocalMessage(
        context,
        tr(context, AppLocaleKey.confirmationPhotoRequired),
      );
      return;
    }

    setState(() => _isBusy = true);
    try {
      final result = _source == _PickupSource.customer
          ? await sl<PickupRepository>().confirmFromCustomer(
              orderId: orders.single.id,
              confirmationImage: orders.single.confirmationImage!,
            )
          : await sl<PickupRepository>().confirmFromMerchant(
              orderIds: orders.map((order) => order.id).toList(),
            );
      if (!mounted) return;
      result.fold(
        (failure) => showLocalMessage(context, failure.errMessage),
        (_) {
          setState(() {
            _currentOrders.clear();
            _customerScanComplete = false;
            _merchantWaitingForNextScan = false;
          });
          unawaited(CommonMethods.cleanupStagingFiles(
            orders.map((order) => order.confirmationImage).toList(),
          ));
          showLocalMessage(context, tr(context, AppLocaleKey.pickupConfirmed));
        },
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  void dispose() {
    final files = _orders.values
        .expand((orders) => orders)
        .map((order) => order.confirmationImage)
        .toList();
    unawaited(CommonMethods.cleanupStagingFiles(files));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, AppLocaleKey.pickup))),
      body: PageBody(
        children: [
          SegmentedButton<_PickupSource>(
            segments: [
              ButtonSegment(
                value: _PickupSource.customer,
                label: Text(tr(context, AppLocaleKey.pickupFromCustomer)),
                icon: const Icon(Icons.person_outline),
              ),
              ButtonSegment(
                value: _PickupSource.merchant,
                label: Text(tr(context, AppLocaleKey.pickupFromMerchant)),
                icon: const Icon(Icons.store_outlined),
              ),
            ],
            selected: {_source},
            onSelectionChanged: _isBusy
                ? null
                : (selection) => setState(() => _source = selection.first),
          ),
          const SizedBox(height: 18),
          Text(
            tr(context, AppLocaleKey.scanInstruction),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          if (_showScanner)
            QrCodeScanner(
              key: _scannerKey,
              isLoading: _isBusy,
              onScan: _onScan,
              description: '',
              title: '',
              showAppBar: false,
            )
          else if (_source == _PickupSource.customer)
            Column(
              children: [
                SurfaceCard(
                  child: Center(
                    child: Text(
                      tr(context, AppLocaleKey.customerPickupScanComplete),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _isBusy ? null : _retryCustomerScan,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(tr(context, AppLocaleKey.retryScanOrder)),
                ),
              ],
            )
          else
            FilledButton.icon(
              onPressed: _isBusy ? null : _scanAnotherMerchantOrder,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(tr(context, AppLocaleKey.scanAnotherOrder)),
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
          if (_source == _PickupSource.customer) ...[
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
              _customerOrderCard(context, _currentOrders.single),
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
                _merchantOrderCard(context, _currentOrders[index], index),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isBusy || _currentOrders.isEmpty ? null : _submitPickup,
            icon: const Icon(Icons.check),
            label: Text(tr(context, AppLocaleKey.submitPickup)),
          ),
        ],
      ),
    );
  }

  Widget _customerOrderCard(
    BuildContext context,
    _ScannedPickupOrder order,
  ) =>
      SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            if (order.confirmationImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  order.confirmationImage!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Icon(Icons.qr_code_2),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                order.id,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            IconButton(
              tooltip: tr(
                context,
                order.confirmationImage == null
                    ? AppLocaleKey.captureConfirmationPhoto
                    : AppLocaleKey.retakeConfirmationPhoto,
              ),
              onPressed:
                  _isBusy ? null : () => _retakeConfirmationImage(order.id),
              icon: Icon(
                order.confirmationImage == null
                    ? Icons.camera_alt_outlined
                    : Icons.refresh,
              ),
            ),
            IconButton(
              tooltip: tr(context, AppLocaleKey.removeOrder),
              onPressed: _isBusy ? null : () => _removeOrder(order.id),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      );

  Widget _merchantOrderCard(
    BuildContext context,
    _ScannedPickupOrder order,
    int index,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.qr_code_2),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${index + 1}. ${order.id}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              IconButton(
                tooltip: tr(context, AppLocaleKey.removeOrder),
                onPressed: _isBusy ? null : () => _removeOrder(order.id),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      );
}
