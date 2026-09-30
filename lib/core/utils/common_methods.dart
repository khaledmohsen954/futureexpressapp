import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:futureexpressapp/core/custom_widgets/custom_toast/custom_toast_animation.dart';
import 'package:futureexpressapp/core/l10n/app_locale_key.dart';
import 'package:futureexpressapp/core/routes/app_routers_import.dart';
import 'package:futureexpressapp/core/theme.dart';
import 'package:image/image.dart' as img;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../services/services_locator_imports.dart';

class CommonMethods {
  // making uploads predictable on mobile connections.static const int uploadMaxBytes = 450 * 10
  // 960px is enough for the odometer/plate evidence while keeping the two
  // image fields in a request comfortably below 1 MB in total.
  static const int uploadMaxDimension = 960;
  static const int uploadMaxBytes = 450 * 1024;
  static const int uploadJpegQuality = 75;

  // اسم فولدر التخزين المؤقت "الآمن" لصور الرفع
  static const String _stagingFolderName = 'futureexpressapp_upload_staging';

  /// بيرجع (وينشئ لو مش موجود) فولدر التخزين الثابت لصور الرفع.
  /// مش cache، فمش هيتمسح تلقائيًا من النظام تحت أي ضغط.
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

  /// بيعمل نسخة مستقرة من فايل صورة جاي من الكاميرا/الـ picker،
  /// بحيث ميندفعش من ضغط النظام على cache/code_cache.
  static Future<File> ensureStableCopy(File file) async {
    if (file.path.isEmpty || !await file.exists()) {
      return file;
    }
    final Directory stagingDir = await _getStagingDir();
    final String uniqueName =
        '${DateTime.now().microsecondsSinceEpoch}_${file.path.split(Platform.pathSeparator).last}';
    final String newPath =
        '${stagingDir.path}${Platform.pathSeparator}$uniqueName';
    return file.copy(newPath);
  }

  static Future<File> compressImage(File file) async {
    if (file.path.isEmpty || !await file.exists()) {
      return file;
    }
    // File size alone is not enough here: a 12 MP image can be smaller than
    // 1 MB but still be expensive to watermark and upload. Always normalize
    // the dimensions before it reaches a multipart request.
    final Uint8List bytes = await file.readAsBytes();
    final Uint8List? result = await compute(_compressTask, bytes);
    if (result == null) return file;

    final Directory stagingDir = await _getStagingDir();
    final String newPath =
        '${stagingDir.path}${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}_${file.path.split(Platform.pathSeparator).last}_compressed.jpg';
    final File newFile = File(newPath);
    await newFile.writeAsBytes(result);
    return newFile;
  }

  static Uint8List? _compressTask(Uint8List bytes) {
    try {
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return null;

      if (image.width > uploadMaxDimension ||
          image.height > uploadMaxDimension) {
        image = img.copyResize(
          image,
          width: uploadMaxDimension,
          height: uploadMaxDimension,
          maintainAspect: true,
        );
      }

      int quality = uploadJpegQuality;
      List<int> compressed = img.encodeJpg(image, quality: quality);

      while (compressed.length > uploadMaxBytes && quality > 40) {
        quality -= 8;
        compressed = img.encodeJpg(image, quality: quality);
      }
      return Uint8List.fromList(compressed);
    } catch (e) {
      return null;
    }
  }

  /// بيمسح فايل أو أكتر بعد ما الرفع للـ API ينجح.
  /// نادي عليها بعد نجاح كل request بيستخدم صور من الـ staging dir.
  static Future<void> cleanupStagingFiles(List<File?> files) async {
    for (final file in files) {
      try {
        if (file != null && await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // تجاهل أي خطأ في المسح، مش critical
      }
    }
  }

  /// بتنضف أي فايلات "قديمة" (نسيت تتمسح بسبب فشل الرفع أو قفل الابليكيشن فجأة).
  /// الأنسب تتنادى مرة واحدة عند بدء التطبيق (main() أو splash screen).
  static Future<void> cleanupOldStagingFiles({
    Duration maxAge = const Duration(hours: 6),
  }) async {
    try {
      final Directory stagingDir = await _getStagingDir();
      if (!await stagingDir.exists()) return;

      final now = DateTime.now();
      await for (final entity in stagingDir.list()) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            if (now.difference(stat.modified) > maxAge) {
              await entity.delete();
            }
          } catch (_) {
            // تجاهل الملف ده واستمر
          }
        }
      }
    } catch (_) {
      // مفيش داعي نوقف التطبيق لو التنضيف فشل
    }
  }

  // Cache to avoid checking too frequently
  static bool? _lastConnectionStatus;
  static DateTime? _lastCheckTime;
  static const _cacheDuration = Duration(seconds: 5);

  static Future<bool> hasConnection() async {
    if (_lastCheckTime != null &&
        _lastConnectionStatus != null &&
        DateTime.now().difference(_lastCheckTime!) < _cacheDuration) {
      return _lastConnectionStatus!;
    }

    try {
      final isConnected = await sl<InternetConnection>()
          .hasInternetAccess
          .timeout(const Duration(milliseconds: 1500), onTimeout: () => true);

      if (isConnected) {
        _lastConnectionStatus = true;
        _lastCheckTime = DateTime.now();
        return true;
      }

      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(milliseconds: 1500), onTimeout: () => []);

      final isActuallyConnected =
          result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      _lastConnectionStatus = isActuallyConnected;
      _lastCheckTime = DateTime.now();
      return isActuallyConnected;
    } catch (e) {
      return true;
    }
  }

  static void showToast({
    required String message,
    String? title,
    String? icon,
    ToastType type = ToastType.success,
    Color? backgroundColor,
    Color? textColor,
    int seconds = 2,
  }) {
    BotToast.showCustomText(
      duration: Duration(seconds: seconds),
      align: Alignment.topCenter,
      wrapAnimation: (controller, cancelFunc, child) =>
          CustomOffsetAnimation(controller: controller, child: child),
      toastBuilder: (cancelFunc) => CustomToast(
        type: type,
        title: title,
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
        textColor: textColor,
      ),
    );
  }

  static void showAlertDialog({
    String? title,
    required String message,
    VoidCallback? onPressed,
  }) {
    showCupertinoDialog(
      context: AppRouters.navigatorKey.currentContext!,
      builder: (context) => CupertinoAlertDialog(
        title: title != null
            ? Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              )
            : null,
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(
              tr(AppLocaleKey.ok),
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppColors.red),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
              if (onPressed != null) onPressed();
            },
          ),
        ],
      ),
    );
  }

  static String toEnglishDigits(String input) {
    const easternArabic = [
      '٠',
      '١',
      '٢',
      '٣',
      '٤',
      '٥',
      '٦',
      '٧',
      '٨',
      '٩',
    ]; // U+0660-U+0669
    const persian = [
      '۰',
      '۱',
      '۲',
      '۳',
      '۴',
      '۵',
      '۶',
      '۷',
      '۸',
      '۹',
    ]; // U+06F0-U+06F9
    for (int i = 0; i < 10; i++) {
      input = input.replaceAll(easternArabic[i], i.toString());
      input = input.replaceAll(persian[i], i.toString());
    }
    return input;
  }
}
