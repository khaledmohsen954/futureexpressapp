import 'dart:math' as math;
import 'package:flutter/material.dart';

class CameraBorderPainter extends CustomPainter {
  final double cornerLength;
  final double strokeWidth;
  final Color color;

  CameraBorderPainter({
    this.cornerLength = 32.0,
    this.strokeWidth = 4.0,
    this.color = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;

    // Corner length scales appropriately so corners never overlap
    final actualCornerLength = math.min(cornerLength, math.min(width, height) / 3);

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      // Top-left corner
      ..moveTo(0, actualCornerLength)
      ..lineTo(0, 0)
      ..lineTo(actualCornerLength, 0)
      // Top-right corner
      ..moveTo(width - actualCornerLength, 0)
      ..lineTo(width, 0)
      ..lineTo(width, actualCornerLength)
      // Bottom-right corner
      ..moveTo(width, height - actualCornerLength)
      ..lineTo(width, height)
      ..lineTo(width - actualCornerLength, height)
      // Bottom-left corner
      ..moveTo(actualCornerLength, height)
      ..lineTo(0, height)
      ..lineTo(0, height - actualCornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CameraBorderPainter oldDelegate) =>
      oldDelegate.cornerLength != cornerLength ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.color != color;
}
