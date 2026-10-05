import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/core/theme.dart';
import 'package:futureexpressapp/core/widgets.dart';
import 'package:futureexpressapp/features/support/data/repositories/app_settings_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateGate extends StatefulWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate> {
  bool _updateRequired = false;
  bool _openingStore = false;
  String? _storeError;
  Uri? _storeUri;

  @override
  void initState() {
    super.initState();
    unawaited(_checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    if (!isAndroid && !isIOS) return;

    try {
      final package = await PackageInfo.fromPlatform();
      final result =
          await sl<AppSettingsRepository>().getAppSettings();
      if (!mounted) return;

      result.fold(
        (failure) => debugPrint(
          'Unable to check for app updates: ${failure.errMessage}',
        ),
        (settings) {
          final minimumVersion = isAndroid
              ? settings.androidMinVersion
              : settings.iosMinVersion;
          if (minimumVersion == null) return;

          try {
            final currentVersion = '${package.version}+${package.buildNumber}';
            if (compareAppVersions(currentVersion, minimumVersion) < 0) {
              setState(() {
                _updateRequired = true;
                _storeUri = Uri.parse(isAndroid
                    ? 'https://play.google.com/store/apps/details?id=com.future.express.v3'
                    : 'https://apps.apple.com/app/id6819175690');
              });
            }
          } on FormatException catch (error) {
            debugPrint('Invalid minimum app version from server: $error');
          }
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Unable to check for app updates: $error\n$stackTrace');
    }
  }

  Future<void> _openStore() async {
    final storeUri = _storeUri;
    if (_openingStore || storeUri == null) return;
    setState(() {
      _openingStore = true;
      _storeError = null;
    });

    try {
      if (!await launchUrl(storeUri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          setState(() => _storeError = tr(context, AppLocaleKey.linkCouldNotOpen));
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Unable to open app store: $error\n$stackTrace');
      if (mounted) {
        setState(() => _storeError = tr(context, AppLocaleKey.linkCouldNotOpen));
      }
    } finally {
      if (mounted) setState(() => _openingStore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_updateRequired) return widget.child;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.system_update_alt,
                    color: AppColors.red,
                    size: 68,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    tr(context, AppLocaleKey.updateRequiredTitle),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr(context, AppLocaleKey.updateRequiredMessage),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ActionButton(
                    label: tr(context, AppLocaleKey.updateNow),
                    icon: Icons.download_outlined,
                    isLoading: _openingStore,
                    onPressed: _openingStore ? null : _openStore,
                  ),
                  if (_storeError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _storeError!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

int compareAppVersions(String current, String minimum) {
  final currentVersion = _parseVersion(current);
  final minimumVersion = _parseVersion(minimum);

  final length = currentVersion.version.length > minimumVersion.version.length
      ? currentVersion.version.length
      : minimumVersion.version.length;
  for (var index = 0; index < length; index++) {
    final currentPart = index < currentVersion.version.length
        ? currentVersion.version[index]
        : 0;
    final minimumPart = index < minimumVersion.version.length
        ? minimumVersion.version[index]
        : 0;
    if (currentPart != minimumPart) {
      return currentPart.compareTo(minimumPart);
    }
  }

  if (minimumVersion.build == null) return 0;
  return (currentVersion.build ?? 0).compareTo(minimumVersion.build!);
}

({List<int> version, int? build}) _parseVersion(String value) {
  final normalized = value.trim().replaceFirst(RegExp(r'^[vV]'), '');
  final sections = normalized.split('+');
  if (sections.length > 2 || sections.first.isEmpty) {
    throw FormatException('Invalid app version: $value');
  }
  final version = sections.first.split('.').map(int.tryParse).toList();
  if (version.isEmpty || version.any((part) => part == null)) {
    throw FormatException('Invalid app version: $value');
  }
  final build = sections.length == 2 ? int.tryParse(sections[1]) : null;
  if (sections.length == 2 && build == null) {
    throw FormatException('Invalid app version: $value');
  }
  return (
    version: version.cast<int>(),
    build: build,
  );
}
