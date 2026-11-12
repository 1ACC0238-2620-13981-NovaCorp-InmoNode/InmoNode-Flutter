// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@Tags(['acceptance', 'US-51'])
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/a_catalog_administrator_is_signed_in.dart';
import './step/the_administrator_creates_the_project_in_with_the_stages.dart';
import './step/the_project_is_created_as.dart';
import './step/the_project_has_the_stages.dart';
import './step/the_project_is_ready_to_receive_lots.dart';
import './step/the_administrator_creates_the_project_without_a_location.dart';
import './step/no_project_is_created.dart';
import './step/the_field_is_marked_with.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Real estate project registration''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await aCatalogAdministratorIsSignedIn(tester);
    }

    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets('''Project created successfully''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Project created successfully''');
        await bddSetUp(tester);
        await theAdministratorCreatesTheProjectInWithTheStages(
            tester, 'Los Pinos', 'Carabayllo, Lima', 'Norte, Sur');
        await theProjectIsCreatedAs(tester, 'Los Pinos', 'Borrador');
        await theProjectHasTheStages(tester, 'Los Pinos', 'Norte, Sur');
        await theProjectIsReadyToReceiveLots(tester, 'Los Pinos');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Project created successfully''',
          success,
        );
      }
    });
    testWidgets('''Registration rejected for missing data''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Registration rejected for missing data''');
        await bddSetUp(tester);
        await theAdministratorCreatesTheProjectWithoutALocation(
            tester, 'Los Pinos');
        await noProjectIsCreated(tester);
        await theFieldIsMarkedWith(
            tester, 'Ubicación *', 'Completa este campo');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Registration rejected for missing data''',
          success,
        );
      }
    });
  });
}
