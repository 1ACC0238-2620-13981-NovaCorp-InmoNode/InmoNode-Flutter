import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';
import '../support/in_memory_accounts.dart';

/// Usage: a catalog administrator is signed in
Future<void> aCatalogAdministratorIsSignedIn(WidgetTester tester) async {
  await startSignedIn(tester, InMemoryAccounts.catalogAdminEmail);
  expect(find.text('Crear proyecto'), findsOneWidget);
}
