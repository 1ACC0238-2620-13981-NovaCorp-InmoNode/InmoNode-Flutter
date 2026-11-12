import 'package:flutter_test/flutter_test.dart';

import '../support/world.dart';

/// Usage: an account already exists for {'luis@mail.com'}
Future<void> anAccountAlreadyExistsFor(WidgetTester tester, String email) async {
  World.current.accounts.seed(email);
}
