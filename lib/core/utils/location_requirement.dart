import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/l10n/app_locale_key.dart';
import 'package:futureexpressapp/core/utils/map_services.dart';

/// Prevents order images from being sent without a location watermark.
class LocationRequirement {
  static Future<bool> ensureForOrderImages(BuildContext context) async {
    final position = await MapService.getCurrentPosition();
    if (position != null) return true;
    if (!context.mounted) return false;

    final status = await MapService.getLocationPermissionStatus();
    if (!context.mounted) return false;

    final needsSettings = status != LocationPermissionStatus.granted;
    final shouldRetry = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocaleKey.locationPermission.tr()),
        content: Text(AppLocaleKey.locationRequiredForOrderImages.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppLocaleKey.cancel.tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop(!needsSettings);
              if (needsSettings) {
                if (status == LocationPermissionStatus.serviceDisabled) {
                  await MapService.openLocationSettings();
                } else {
                  await MapService.openAppSettings();
                }
              }
            },
            child: Text(
              needsSettings ? AppLocaleKey.openSettings.tr() : AppLocaleKey.tryAgain.tr(),
            ),
          ),
        ],
      ),
    );
    return shouldRetry == true && context.mounted ? ensureForOrderImages(context) : false;
  }
}
