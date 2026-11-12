// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@Tags(['acceptance', 'US-53'])
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_project_was_created_with_the_stages.dart';
import './step/its_lot_was_registered_at_with_its_polygon.dart';
import './step/a_catalog_administrator_is_signed_in.dart';
import './step/the_administrator_opens_the_project.dart';
import './step/the_administrator_publishes_the_project.dart';
import './step/the_administrator_publishes_the_lot.dart';
import './step/the_project_lists_the_lot_in_the_stage_as.dart';
import './step/a_buyer_finds_the_lot_of_available_in_the_catalog.dart';
import './step/the_administrator_registers_the_lot_without_its.dart';
import './step/the_lot_is_not_registered_so_it_cannot_be_published.dart';
import './step/the_field_is_marked_with.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Lot publication to the catalog''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theProjectWasCreatedWithTheStages(
          tester, 'Los Pinos', 'Norte, Sur');
      await itsLotWasRegisteredAtWithItsPolygon(tester, 'N-01', 45000);
      await aCatalogAdministratorIsSignedIn(tester);
      await theAdministratorOpensTheProject(tester, 'Los Pinos');
    }

    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets('''Successful publication''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Successful publication''');
        await bddSetUp(tester);
        await theAdministratorPublishesTheProject(tester);
        await theAdministratorPublishesTheLot(tester, 'N-01');
        await theProjectListsTheLotInTheStageAs(
            tester, 'Los Pinos', 'N-01', 'Norte', 'Disponible');
        await aBuyerFindsTheLotOfAvailableInTheCatalog(
            tester, 'N-01', 'Los Pinos');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Successful publication''',
          success,
        );
      }
    });
    testWidgets(
        '''Publication blocked by missing data (price, Precio (S/) *, Ingresa el precio en soles, por ejemplo 45000 o 45,000.50)''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Publication blocked by missing data (price, Precio (S/) *, Ingresa el precio en soles, por ejemplo 45000 o 45,000.50)''');
        await bddSetUp(tester);
        await theAdministratorRegistersTheLotWithoutIts(
            tester, 'N-02', 'price');
        await theLotIsNotRegisteredSoItCannotBePublished(tester, 'N-02');
        await theFieldIsMarkedWith(tester, 'Precio (S/) *',
            'Ingresa el precio en soles, por ejemplo 45000 o 45,000.50');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Publication blocked by missing data (price, Precio (S/) *, Ingresa el precio en soles, por ejemplo 45000 o 45,000.50)''',
          success,
        );
      }
    });
    testWidgets(
        '''Publication blocked by missing data (polygon, Polígono: longitud,latitud por línea *, Ingresa al menos 3 vértices, uno por línea)''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Publication blocked by missing data (polygon, Polígono: longitud,latitud por línea *, Ingresa al menos 3 vértices, uno por línea)''');
        await bddSetUp(tester);
        await theAdministratorRegistersTheLotWithoutIts(
            tester, 'N-02', 'polygon');
        await theLotIsNotRegisteredSoItCannotBePublished(tester, 'N-02');
        await theFieldIsMarkedWith(
            tester,
            'Polígono: longitud,latitud por línea *',
            'Ingresa al menos 3 vértices, uno por línea');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Publication blocked by missing data (polygon, Polígono: longitud,latitud por línea *, Ingresa al menos 3 vértices, uno por línea)''',
          success,
        );
      }
    });
  });
}
