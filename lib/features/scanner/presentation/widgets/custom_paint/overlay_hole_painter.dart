// Put this CustomPainter class somewhere accessible in the file
import 'package:flutter/material.dart';

class OverlayHolePainter extends CustomPainter {
  final double holeWidth;
  final double holeHeight;
  final double borderRadius;
  final Color overlayColor;

  OverlayHolePainter({
    double? holeSize,
    double? holeWidth,
    double? holeHeight,
    this.borderRadius = 15.0,
    this.overlayColor = const Color.fromARGB(190, 0, 0, 0),
  })  : holeWidth = holeWidth ?? holeSize ?? 250,
        holeHeight = holeHeight ?? holeSize ?? 250;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // draw full overlay on a layer
    canvas.saveLayer(rect, Paint());
    final paint = Paint()..color = overlayColor;
    canvas.drawRect(rect, paint);

    // compute hole rect (centered)
    final holeRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: holeWidth,
      height: holeHeight,
    );

    // clear the hole
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    final rrect = RRect.fromRectAndRadius(
      holeRect,
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(rrect, clearPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant OverlayHolePainter oldDelegate) =>
      oldDelegate.holeWidth != holeWidth ||
      oldDelegate.holeHeight != holeHeight ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.overlayColor != overlayColor;
}
