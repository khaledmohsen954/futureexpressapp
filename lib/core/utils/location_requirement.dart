import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/utils/map_services.dart';

/// Checks and requests location access before location-dependent operations.
class LocationRequirement {
  static Future<bool> requestOnAppOpen(BuildContext context) async {
    LocationPermissionStatus status;
    try {
      status = await MapService.requestLocationPermission();
    } on PlatformException {
      return false;
    } on StateError {
      return false;
    }

    if (!context.mounted) return false;
    if (status == LocationPermissionStatus.granted) return true;
    return _showLocationPrompt(
      context,
      status,
      AppLocaleKey.shipmentStatusLocationRequired,
      requestOnAppOpen,
    );
  }

  static Future<bool> ensureForShipmentStatus(BuildContext context) async {
    try {
      final position = await MapService.getCurrentPosition(forceRefresh: true);
      if (position != null) return true;
    } on PlatformException {
      if (!context.mounted) return false;
    } on StateError {
      if (!context.mounted) return false;
    }
    if (!context.mounted) return false;

    LocationPermissionStatus status;
    try {
      status = await MapService.getLocationPermissionStatus();
    } on PlatformException {
      status = LocationPermissionStatus.denied;
    } on StateError {
      status = LocationPermissionStatus.denied;
    }
    if (!context.mounted) return false;

    return _showLocationPrompt(
      context,
      status,
      AppLocaleKey.shipmentStatusLocationRequired,
      ensureForShipmentStatus,
    );
  }

  /// Prevents order images from being sent without a location watermark.
  static Future<bool> ensureForOrderImages(BuildContext context) async {
    final position = await MapService.getCurrentPosition();
    if (position != null) return true;
    if (!context.mounted) return false;

    final status = await MapService.getLocationPermissionStatus();
    if (!context.mounted) return false;

    return _showLocationPrompt(
      context,
      status,
      AppLocaleKey.locationRequiredForOrderImages,
      ensureForOrderImages,
    );
  }

  static Future<bool> _showLocationPrompt(
    BuildContext context,
    LocationPermissionStatus status,
    String descriptionKey,
    Future<bool> Function(BuildContext) retry,
  ) async {
    if (!context.mounted) return false;
    final needsSettings = status == LocationPermissionStatus.deniedForever ||
        status == LocationPermissionStatus.serviceDisabled;
    final openSettings = status == LocationPermissionStatus.serviceDisabled
        ? MapService.openLocationSettings
        : MapService.openAppSettings;
    final action = await showDialog<_LocationPromptAction>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          tr(
            dialogContext,
            status == LocationPermissionStatus.serviceDisabled
                ? AppLocaleKey.locationServiceDisabled
                : AppLocaleKey.locationPermission,
          ),
        ),
        content: Text(tr(dialogContext, descriptionKey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              _LocationPromptAction.cancel,
            ),
            child: Text(tr(dialogContext, AppLocaleKey.cancel)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              needsSettings
                  ? _LocationPromptAction.settings
                  : _LocationPromptAction.retry,
            ),
            child: Text(
              tr(
                dialogContext,
                needsSettings
                    ? AppLocaleKey.openSettings
                    : AppLocaleKey.tryAgain,
              ),
            ),
          ),
        ],
      ),
    );
    if (!context.mounted ||
        action == null ||
        action == _LocationPromptAction.cancel) {
      return false;
    }
    if (action == _LocationPromptAction.settings) {
      await openSettings();
      if (!context.mounted) return false;
    }
    return retry(context);
  }
}

enum _LocationPromptAction { cancel, retry, settings }
