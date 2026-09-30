import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/session/auth_session.dart';

void main() {
  tearDown(() => AuthSession.onUnauthenticated = null);

  test('clears the session only once for concurrent unauthorized responses',
      () async {
    var invocationCount = 0;
    AuthSession.onUnauthenticated = () async {
      invocationCount++;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    };

    await Future.wait([AuthSession.expire(), AuthSession.expire()]);

    expect(invocationCount, 1);
  });
}
