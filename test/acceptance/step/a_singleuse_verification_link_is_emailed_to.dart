import 'package:flutter_test/flutter_test.dart';

import '../support/world.dart';

/// Usage: a single-use verification link is emailed to {'ana@mail.com'}
Future<void> aSingleuseVerificationLinkIsEmailedTo(WidgetTester tester, String email) async {
  expect(World.current.accounts.verificationLinks[email], hasLength(1));
}
