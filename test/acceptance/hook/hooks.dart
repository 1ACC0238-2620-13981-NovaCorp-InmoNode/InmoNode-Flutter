import 'dart:async';

import '../support/world.dart';

/// Each scenario runs against new in-memory Web Services and a fresh dependency container.
abstract class Hooks {
  const Hooks._();

  static FutureOr<void> beforeEach(String title, [List<String>? tags]) {
    World.begin();
  }

  static FutureOr<void> beforeAll() {}

  static FutureOr<void> afterEach(
    String title,
    bool success, [
    List<String>? tags,
  ]) {
    return World.end();
  }

  static FutureOr<void> afterAll() {}
}
