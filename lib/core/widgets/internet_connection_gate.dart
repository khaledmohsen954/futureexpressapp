import 'dart:async';

import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/core/theme.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetConnectionGate extends StatefulWidget {
  const InternetConnectionGate({super.key, required this.child});

  final Widget child;

  @override
  State<InternetConnectionGate> createState() => _InternetConnectionGateState();
}

class _InternetConnectionGateState extends State<InternetConnectionGate> {
  late final InternetConnection _internetConnection;
  StreamSubscription<InternetStatus>? _subscription;
  bool _isOffline = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _internetConnection = sl<InternetConnection>();
    _subscription = _internetConnection.onStatusChange.listen(
      _onStatusChanged,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Internet connectivity stream failed: $error\n$stackTrace');
      },
    );
    unawaited(_checkConnection());
  }

  void _onStatusChanged(InternetStatus status) {
    if (!mounted) return;
    final isOffline = status == InternetStatus.disconnected;
    if (_isOffline != isOffline) {
      setState(() => _isOffline = isOffline);
    }
  }

  Future<void> _checkConnection() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    try {
      final isConnected = await _internetConnection.hasInternetAccess.timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );
      if (mounted) setState(() => _isOffline = !isConnected);
    } catch (error, stackTrace) {
      debugPrint('Unable to check internet connectivity: $error\n$stackTrace');
      if (mounted) setState(() => _isOffline = true);
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_isOffline)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black54,
              child: Center(
                child: AlertDialog(
                  icon: const Icon(
                    Icons.wifi_off_rounded,
                    color: AppColors.red,
                    size: 40,
                  ),
                  title: Text(tr(context, AppLocaleKey.noInternetTitle)),
                  content: Text(
                    tr(context, AppLocaleKey.noInternetMessage),
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    TextButton(
                      onPressed: _isChecking ? null : _checkConnection,
                      child: _isChecking
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(tr(context, AppLocaleKey.retryConnection)),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    return _isOffline ? PopScope(canPop: false, child: content) : content;
  }
}
