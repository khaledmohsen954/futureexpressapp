import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/custom_widgets/buttons/custom_button.dart';
import 'package:futureexpressapp/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:futureexpressapp/core/l10n/app_locale_key.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart' as app_strings;
import 'package:futureexpressapp/core/theme/app_colors.dart';
import 'package:futureexpressapp/features/scanner/presentation/widgets/custom_paint/camera_border_painter.dart';
import 'package:futureexpressapp/features/scanner/presentation/widgets/custom_paint/overlay_hole_painter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum ScannerShapeMode {
  qr, // مربع
  barcode, // مستطيل
}

class QrCodeScanner extends StatefulWidget {
  final String title;
  final String description;
  final FutureOr<void> Function(String value) onScan;
  final bool showAppBar;
  final List<BarcodeFormat> formats;
  final bool? isLoading;
  final ScannerShapeMode initialMode;
  final ScannerShapeMode? mode;
  final ValueChanged<ScannerShapeMode>? onModeChanged;
  final bool showModeSelector;

  const QrCodeScanner({
    super.key,
    required this.title,
    required this.description,
    required this.onScan,
    this.showAppBar = true,
    this.formats = const [BarcodeFormat.all],
    this.isLoading,
    this.initialMode = ScannerShapeMode.qr,
    this.mode,
    this.onModeChanged,
    this.showModeSelector = true,
  });

  @override
  State<QrCodeScanner> createState() => QrCodeScannerState();
}

class QrCodeScannerState extends State<QrCodeScanner>
    with WidgetsBindingObserver {
  final ValueNotifier<bool> detected = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  late final ValueNotifier<ScannerShapeMode> shapeMode;

  late final MobileScannerController controller;
  final ValueNotifier<double> zoomLevel = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    shapeMode =
        ValueNotifier<ScannerShapeMode>(widget.mode ?? widget.initialMode);

    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      returnImage: false,
      formats: widget.formats,
    );
  }

  @override
  void didUpdateWidget(covariant QrCodeScanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode != null && widget.mode != shapeMode.value) {
      shapeMode.value = widget.mode!;
    }
  }

  void setMode(ScannerShapeMode newMode) {
    if (shapeMode.value == newMode) return;
    shapeMode.value = newMode;
    widget.onModeChanged?.call(newMode);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    zoomLevel.dispose();
    detected.dispose();
    isLoading.dispose();
    shapeMode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted || !controller.value.isInitialized) return;

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        unawaited(controller.stop());
      case AppLifecycleState.resumed:
        if (!detected.value) {
          unawaited(controller.start());
        }
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> _handleScan(String value) async {
    final raw = value.trim();
    isLoading.value = true;
    try {
      await Future.sync(() => widget.onScan(raw));
    } finally {
      if (mounted) {
        detected.value = false;
        isLoading.value = false;

        try {
          if (controller.value.isRunning) {
            await controller.stop();
          }
          await controller.start();
        } catch (e) {
          debugPrint('Error resetting scanner after scan: $e');
        }
      }
    }
  }

  Future<void> restart() async {
    detected.value = false;
    isLoading.value = false;
    if (controller.value.isRunning) {
      await controller.stop();
    }
    await controller.start();
  }

  void pauseDetection() {
    detected.value = true;
  }

  Future<void> stop() async {
    try {
      if (controller.value.isRunning) {
        await controller.stop();
      }
    } catch (e) {
      debugPrint('Error stopping scanner: $e');
    }
  }

  Future<void> start() async {
    try {
      if (!controller.value.isRunning) {
        await controller.start();
      }
    } catch (e) {
      debugPrint('Error starting scanner: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double scannerHeight = size.height * 0.5;

    return SizedBox(
      height: scannerHeight,
      child: Stack(
        children: [
          // Camera
          RepaintBoundary(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: MobileScanner(
                controller: controller,
                onDetect: (capture) async {
                  if (detected.value) return;

                  try {
                    for (final barcode in capture.barcodes) {
                      final raw = barcode.rawValue?.trim();
                      if (raw != null && raw.isNotEmpty) {
                        log('Detected ${barcode.format.name}: $raw');
                        detected.value = true;
                        isLoading.value = true;

                        await _handleScan(raw);
                        break;
                      }
                    }
                  } catch (e, st) {
                    debugPrint('QR/Barcode read error: $e\n$st');
                    if (mounted) {
                      detected.value = false;
                      isLoading.value = false;
                    }
                  }
                },
              ),
            ),
          ),

          // Overlay + corner borders (مربع للـ QR / مستطيل للباركود)
          ValueListenableBuilder<ScannerShapeMode>(
            valueListenable: shapeMode,
            builder: (context, currentMode, _) {
              final bool isQr = currentMode == ScannerShapeMode.qr;
              final double targetW =
                  isQr ? size.width * 0.65 : size.width * 0.84;
              final double targetH = isQr ? size.width * 0.65 : 135.0;

              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOut,
                tween: Tween<double>(end: targetW),
                builder: (context, holeWidth, _) {
                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOut,
                    tween: Tween<double>(end: targetH),
                    builder: (context, holeHeight, _) {
                      return Stack(
                        children: [
                          // Dark overlay with hole
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CustomPaint(
                                painter: OverlayHolePainter(
                                  holeWidth: holeWidth,
                                  holeHeight: holeHeight,
                                  borderRadius: 15,
                                  overlayColor: AppColor.blackColor(context)
                                      .withAlpha(200),
                                ),
                              ),
                            ),
                          ),

                          // Corner borders
                          Center(
                            child: CustomPaint(
                              foregroundPainter: CameraBorderPainter(),
                              child: SizedBox(
                                width: holeWidth,
                                height: holeHeight,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),

          // Mode selector: QR (Square) / Barcode (Rectangle)
          if (widget.showModeSelector)
            Positioned(
              top: 14,
              left: 20,
              right: 20,
              child: ValueListenableBuilder<ScannerShapeMode>(
                valueListenable: shapeMode,
                builder: (context, currentMode, _) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _modeButton(
                            context: context,
                            title: app_strings.tr(context, AppLocaleKey.qrCode),
                            icon: Icons.qr_code_2_rounded,
                            isSelected: currentMode == ScannerShapeMode.qr,
                            onTap: () => setMode(ScannerShapeMode.qr),
                          ),
                          const SizedBox(width: 4),
                          _modeButton(
                            context: context,
                            title:
                                app_strings.tr(context, AppLocaleKey.barcode),
                            icon: Icons.view_week_rounded,
                            isSelected: currentMode == ScannerShapeMode.barcode,
                            onTap: () => setMode(ScannerShapeMode.barcode),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Instruction + zoom slider
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // SizedBox(
                //   height: 50,
                // ),
                // ValueListenableBuilder<ScannerShapeMode>(
                //   valueListenable: shapeMode,
                //   builder: (context, currentMode, _) {
                //     final instruction = currentMode == ScannerShapeMode.qr
                //         ? app_strings.tr(context, AppLocaleKey.pleasePositionQrWithinFrame)
                //         : (Localizations.localeOf(context).languageCode == 'ar'
                //             ? 'يرجى وضع الباركود داخل الإطار'
                //             : 'Please position barcode within frame');
                //     return Text(
                //       instruction,
                //       style: AppTextStyle.textW14B(context),
                //     );
                //   },
                // ),
                const SizedBox(height: 10),
                Material(
                  color: Colors.transparent,
                  child: SliderTheme(
                    data: const SliderThemeData(
                      trackHeight: 10,
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 20.0),
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: 20.0),
                    ),
                    child: ValueListenableBuilder<double>(
                      valueListenable: zoomLevel,
                      builder: (context, value, _) {
                        return Slider(
                          thumbColor: AppColor.whiteColor(context),
                          inactiveColor: AppColor.lightGreyColor(context),
                          activeColor: AppColor.sliderColor(context),
                          value: value,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (newValue) {
                            zoomLevel.value = newValue;
                            unawaited(controller.setZoomScale(newValue));
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay
          ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (context, loading, _) {
              final isBusy = loading || (widget.isLoading ?? false);
              if (!isBusy) return const SizedBox.shrink();
              return Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: CustomLoading(size: 45),
                  ),
                ),
              );
            },
          ),

          // Retry button
          ValueListenableBuilder<bool>(
            valueListenable: detected,
            builder: (context, isDetected, _) {
              if (!isDetected) return const SizedBox.shrink();
              return ValueListenableBuilder<bool>(
                valueListenable: isLoading,
                builder: (context, loading, _) {
                  final isBusy = loading || (widget.isLoading ?? false);
                  if (isBusy) return const SizedBox.shrink();
                  return Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: CustomButton(
                      text: app_strings.tr(context, AppLocaleKey.retry),
                      color: AppColor.mainAppColor(context),
                      onPressed: () {
                        detected.value = false;
                        isLoading.value = false;
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _modeButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColor.mainAppColor(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
