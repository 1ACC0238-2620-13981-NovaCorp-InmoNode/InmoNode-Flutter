import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/iam/domain/account.dart';

import '../support/world.dart';

/// Usage: the account {'ana@mail.com'} is created as inactive
Future<void> theAccountIsCreatedAsInactive(WidgetTester tester, String email) async {
  final world = World.current;
  expect(world.accounts.count, world.accountsBefore + 1);
  expect(world.accounts.find(email)?.status, AccountStatus.inactive);
}
