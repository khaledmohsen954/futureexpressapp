import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'map_services.dart';

class ImageWatermarkHelper {
  static const String _stagingFolderName = 'futureexpressapp_upload_staging';
  static const int _maxDimension = 960;
  static const int _maxBytes = 450 * 1024;
  static const int _jpegQuality = 75;

  static Future<Directory> _getStagingDir() async {
    final Directory supportDir = await getApplicationSupportDirectory();

    final Directory stagingDir = Directory(
      '${supportDir.path}${Platform.pathSeparator}$_stagingFolderName',
    );

    if (!await stagingDir.exists()) {
      await stagingDir.create(recursive: true);
    }

    return stagingDir;
  }

  /// Add watermark to image.
  ///
  /// Pass [position] if you already have the user's location.
  /// This avoids requesting GPS again for every image.
  static Future<File> addWatermark(
    File imageFile, {
    double? latitude,
    double? longitude,
  }) async {
    if (imageFile.path.isEmpty || !await imageFile.exists()) {
      throw StateError('Cannot watermark a missing image file.');
    }

    final now = DateTime.now();

    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final timeStr = DateFormat('HH:mm:ss').format(now);

    String latStr = 'N/A';
    String lngStr = 'N/A';

    // Use existing location if available.
    if (latitude != null && longitude != null) {
      latStr = latitude.toStringAsFixed(6);
      lngStr = longitude.toStringAsFixed(6);
    } else {
      // Fallback only if location was not already provided.
      try {
        final position = MapService.currentPosition;

        if (position != null) {
          latStr = position.latitude.toStringAsFixed(6);
          lngStr = position.longitude.toStringAsFixed(6);
        }
      } catch (_) {}
    }

    final line1 = 'Date: $dateStr   Time: $timeStr';
    final line2 = 'Lat: $latStr   Lng: $lngStr';

    final Uint8List bytes = await imageFile.readAsBytes();

    final Uint8List? result = await compute(
      _applyWatermark,
      _WatermarkParams(imageBytes: bytes, line1: line1, line2: line2),
    );

    if (result == null) {
      throw StateError(
        'Could not add the date and time watermark to the image.',
      );
    }

    final Directory stagingDir = await _getStagingDir();

    final String baseName = imageFile.path.split(Platform.pathSeparator).last;

    final String newPath = '${stagingDir.path}${Platform.pathSeparator}'
        '${DateTime.now().microsecondsSinceEpoch}_'
        '${baseName}_watermarked.jpg';

    final File newFile = File(newPath);

    await newFile.writeAsBytes(result, flush: false);

    if (!await newFile.exists() || await newFile.length() == 0) {
      throw StateError('Could not create the timestamped image file.');
    }

    return newFile;
  }

  static Uint8List? _applyWatermark(_WatermarkParams params) {
    try {
      img.Image? image = img.decodeImage(params.imageBytes);

      if (image == null) {
        return null;
      }

      // Watermarking used to preserve the camera's original resolution. That
      // made the timestamped copy much larger than the normal upload. Limit it
      // before drawing so CPU work and the multipart payload stay small.
      if (image.width > _maxDimension || image.height > _maxDimension) {
        image = img.copyResize(
          image,
          width: _maxDimension,
          height: _maxDimension,
          maintainAspect: true,
        );
      }

      img.BitmapFont font;
      int padding;
      int lineHeight;

      if (image.width < 500) {
        font = img.arial14;
        padding = 6;
        lineHeight = 18;
      } else if (image.width < 1000) {
        font = img.arial24;
        padding = 10;
        lineHeight = 28;
      } else {
        font = img.arial48;
        padding = 20;
        lineHeight = 55;
      }

      final int bgHeight = (lineHeight * 2) + (padding * 3);

      final int bgTop = image.height - bgHeight;

      img.fillRect(
        image,
        x1: 0,
        y1: bgTop,
        x2: image.width,
        y2: image.height,
        color: img.ColorRgba8(0, 0, 0, 160),
      );

      final int y1 = bgTop + padding;

      img.drawString(
        image,
        params.line1,
        font: font,
        x: padding,
        y: y1,
        color: img.ColorRgba8(255, 255, 255, 255),
      );

      final int y2 = y1 + lineHeight;

      img.drawString(
        image,
        params.line2,
        font: font,
        x: padding,
        y: y2,
        color: img.ColorRgba8(255, 255, 255, 255),
      );

      int quality = _jpegQuality;
      List<int> encoded = img.encodeJpg(image, quality: quality);
      while (encoded.length > _maxBytes && quality > 40) {
        quality -= 8;
        encoded = img.encodeJpg(image, quality: quality);
      }
      return Uint8List.fromList(encoded);
    } catch (_) {
      return null;
    }
  }
}

class _WatermarkParams {
  final Uint8List imageBytes;
  final String line1;
  final String line2;

  _WatermarkParams({
    required this.imageBytes,
    required this.line1,
    required this.line2,
  });
}
