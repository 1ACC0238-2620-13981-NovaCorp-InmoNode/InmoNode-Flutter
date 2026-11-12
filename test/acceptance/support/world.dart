import 'package:inmonode/core/di/dependency_injection.dart';

import 'in_memory_accounts.dart';
import 'in_memory_catalog.dart';
import 'in_memory_quotations.dart';

/// The state of one scenario: the in-memory Web Services the app talks to and what the steps remember.
///
/// The hooks start a new world before each scenario and drop it afterwards, so no scenario sees the data of
/// another one.
class World {
  static World? _current;

  static World get current => _current ?? (throw StateError('No acceptance scenario is running'));

  static void begin() => _current = World._();

  static Future<void> end() async {
    _current = null;
    await getIt.reset();
  }

  World._();

  final InMemoryAccounts accounts = InMemoryAccounts();
  final InMemorySessions sessions = InMemorySessions();
  final InMemoryCatalog catalog = InMemoryCatalog();
  late final InMemoryQuotations quotations = InMemoryQuotations(catalog);

  /// Number of accounts before the scenario's action, to tell whether it created one.
  int accountsBefore = 0;
}
