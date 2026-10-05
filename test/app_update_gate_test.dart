import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/features/support/presentation/widgets/app_update_gate.dart';

void main() {
  test('compares semantic versions numerically', () {
    expect(compareAppVersions('1.10.0', '1.9.9'), greaterThan(0));
    expect(compareAppVersions('1.2.3', '1.2.4'), lessThan(0));
    expect(compareAppVersions('1.2', '1.2.0'), 0);
  });

  test('compares build numbers when the minimum includes one', () {
    expect(compareAppVersions('1.2.3+8', '1.2.3+7'), greaterThan(0));
    expect(compareAppVersions('1.2.3+6', '1.2.3+7'), lessThan(0));
    expect(compareAppVersions('1.2.3', '1.2.3+1'), lessThan(0));
  });

  test('rejects malformed versions', () {
    expect(
      () => compareAppVersions('1.2.bad', '1.2.3'),
      throwsFormatException,
    );
  });
}
