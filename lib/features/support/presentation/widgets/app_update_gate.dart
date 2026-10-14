import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

class AppUpdateGate extends StatefulWidget {
  const AppUpdateGate({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate> {
  // instance واحدة بدل ما تتعمل من جديد مع كل rebuild
  late final Upgrader _upgrader = Upgrader(
    countryCode: 'SA',
    durationUntilAlertAgain: const Duration(hours: 1),
    // debugDisplayAlways: true, // للتجربة فقط، شيلها قبل الرفع
  );

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      navigatorKey: widget.navigatorKey,
      upgrader: _upgrader,
      showIgnore: false,
      showLater: true,
      barrierDismissible: false,
      child: widget.child,
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
