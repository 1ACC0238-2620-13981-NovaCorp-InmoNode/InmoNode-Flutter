// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@Tags(['acceptance', 'US-52'])
import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_project_was_created_with_the_stages.dart';
import './step/a_catalog_administrator_is_signed_in.dart';
import './step/the_administrator_opens_the_project.dart';
import './step/the_administrator_registers_this_lot.dart';
import './step/the_project_lists_the_lot_in_the_stage_as.dart';
import './step/the_lot_is_saved_with_an_area_of_and_a_price_of.dart';
import './step/buyers_cannot_see_the_lot.dart';
import './step/the_administrator_registers_the_lot_with_the_polygon.dart';
import './step/the_lot_is_not_saved.dart';
import './step/the_administrator_is_asked_to_fix_the_polygon_with.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Lot registration with its technical sheet and cadastral polygon''',
      () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theProjectWasCreatedWithTheStages(
          tester, 'Los Pinos', 'Norte, Sur');
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

    testWidgets('''Lot registered in an existing project''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Lot registered in an existing project''');
        await bddSetUp(tester);
        await theAdministratorRegistersThisLot(
            tester,
            const bdd.DataTable([
              ['code', 'stage', 'area', 'front', 'depth', 'price', 'polygon'],
              [
                'N-01',
                'Sur',
                120,
                8,
                15,
                45000,
                '-77.0428,-12.0464; -77.0427,-12.0464; -77.0427,-12.0465; -77.0428,-12.0465'
              ]
            ]));
        await theProjectListsTheLotInTheStageAs(
            tester, 'Los Pinos', 'N-01', 'Sur', 'Borrador');
        await theLotIsSavedWithAnAreaOfAndAPriceOf(tester, 'N-01', 120, 45000);
        await buyersCannotSeeTheLot(tester, 'N-01');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Lot registered in an existing project''',
          success,
        );
      }
    });
    testWidgets(
        '''Invalid polygon rejected (-77.0428,-12.0464; -77.0427,-12.0465; -77.0427,-12.0464; -77.0428,-12.0465, El polígono se cruza consigo mismo o no tiene área. Revisa el orden de los vértices.)''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Invalid polygon rejected (-77.0428,-12.0464; -77.0427,-12.0465; -77.0427,-12.0464; -77.0428,-12.0465, El polígono se cruza consigo mismo o no tiene área. Revisa el orden de los vértices.)''');
        await bddSetUp(tester);
        await theAdministratorRegistersTheLotWithThePolygon(tester, 'N-02',
            '-77.0428,-12.0464; -77.0427,-12.0465; -77.0427,-12.0464; -77.0428,-12.0465');
        await theLotIsNotSaved(tester, 'N-02');
        await theAdministratorIsAskedToFixThePolygonWith(tester,
            'El polígono se cruza consigo mismo o no tiene área. Revisa el orden de los vértices.');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Invalid polygon rejected (-77.0428,-12.0464; -77.0427,-12.0465; -77.0427,-12.0464; -77.0428,-12.0465, El polígono se cruza consigo mismo o no tiene área. Revisa el orden de los vértices.)''',
          success,
        );
      }
    });
    testWidgets(
        '''Invalid polygon rejected (-77.0428,-12.0464; -77.0427,-12.0464, Ingresa al menos 3 vértices, uno por línea)''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Invalid polygon rejected (-77.0428,-12.0464; -77.0427,-12.0464, Ingresa al menos 3 vértices, uno por línea)''');
        await bddSetUp(tester);
        await theAdministratorRegistersTheLotWithThePolygon(
            tester, 'N-02', '-77.0428,-12.0464; -77.0427,-12.0464');
        await theLotIsNotSaved(tester, 'N-02');
        await theAdministratorIsAskedToFixThePolygonWith(
            tester, 'Ingresa al menos 3 vértices, uno por línea');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Invalid polygon rejected (-77.0428,-12.0464; -77.0427,-12.0464, Ingresa al menos 3 vértices, uno por línea)''',
          success,
        );
      }
    });
  });
}
