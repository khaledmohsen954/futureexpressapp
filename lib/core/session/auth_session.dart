import 'dart:developer';

typedef UnauthenticatedHandler = Future<void> Function();

class AuthSession {
  AuthSession._();

  static UnauthenticatedHandler? onUnauthenticated;
  static Future<void>? _expiration;

  static Future<void> expire() async {
    if (_expiration case final expiration?) {
      await expiration;
      return;
    }

    final handler = onUnauthenticated;
    if (handler == null) return;

    final expiration = handler();
    _expiration = expiration;
    try {
      await expiration;
    } catch (error, stackTrace) {
      log(
        'Failed to clear session after unauthenticated API response.',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      if (identical(_expiration, expiration)) _expiration = null;
    }
  }
}
