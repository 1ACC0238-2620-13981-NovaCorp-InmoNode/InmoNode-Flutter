import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';
import '../support/in_memory_accounts.dart';

/// Usage: a buyer is signed in
Future<void> aBuyerIsSignedIn(WidgetTester tester) async {
  await startSignedIn(tester, InMemoryAccounts.buyerEmail);
}
