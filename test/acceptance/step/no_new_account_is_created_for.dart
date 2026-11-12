import 'package:flutter_test/flutter_test.dart';

import '../support/world.dart';

/// Usage: no new account is created for {'luis@mail.com'}
Future<void> noNewAccountIsCreatedFor(WidgetTester tester, String email) async {
  final world = World.current;
  expect(world.accounts.count, world.accountsBefore);
  expect(world.accounts.verificationLinks[email], isNull);
}
