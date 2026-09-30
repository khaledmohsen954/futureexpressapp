import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:futureexpressapp/features/scanner/presentation/widgets/qr_code_scanner.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey<QrCodeScannerState> scannerKey = GlobalKey<QrCodeScannerState>();
  String? _detectedCodeValue;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, AppLocaleKey.pickup))),
      body: PageBody(children: [
        Text(tr(context, AppLocaleKey.scanInstruction),
            textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 22),
        QrCodeScanner(
          key: scannerKey,
          isLoading: _isLoading,
          onScan: (value) async {
            debugPrint('Detected QR / Barcode: $value');
            // ignore: avoid_print
            print('Detected QR / Barcode: $value');
            setState(() {
              _isLoading = true;
            });

            // Simulate processing / network verification delay so loading animation is visible
            await Future.delayed(const Duration(milliseconds: 600));

            if (!context.mounted) return;
            setState(() {
              _isLoading = false;
              _detectedCodeValue = value;
            });
            showLocalMessage(context, value);
          },
          description: "",
          title: "",
          showAppBar: false,
        ),
        if (_isLoading) ...[
          const SizedBox(height: 14),
          const SurfaceCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CustomLoading(size: 32),
              ),
            ),
          ),
        ] else if (_detectedCodeValue != null) ...[
          const SizedBox(height: 14),
          SurfaceCard(
            child: Row(
              children: [
                const Icon(Icons.qr_code_2, color: AppColors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QR / Barcode Value',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.muted,
                            ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        _detectedCodeValue!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        ActionButton(
            label: tr(context, AppLocaleKey.scanDemo),
            icon: Icons.qr_code_scanner,
            onPressed: () {
              final shipment = state.pickupNext();
              showLocalMessage(
                  context,
                  tr(context,
                      shipment == null ? AppLocaleKey.noPending : AppLocaleKey.pickupSuccess));
            }),
        const SizedBox(height: 14),
        SurfaceCard(
            child: Row(children: [
          const Icon(Icons.inventory_2_outlined, color: AppColors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(tr(context, AppLocaleKey.pickedUpToday))),
          Text('${state.pickedUpIds.length} / ${state.shipments.length}',
              style: Theme.of(context).textTheme.labelLarge),
        ])),
      ]),
    );
  }
}
