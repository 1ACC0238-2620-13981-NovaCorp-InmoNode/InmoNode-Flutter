// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@Tags(['acceptance', 'US-15'])
import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_published_project_in_with_these_lots.dart';
import './step/a_buyer_is_signed_in.dart';
import './step/the_buyer_opens_the_project_catalog.dart';
import './step/the_catalog_lists_the_projects.dart';
import './step/the_project_shows_a_thumbnail.dart';
import './step/the_project_shows_the_price_range.dart';
import './step/the_project_shows_the_availability.dart';
import './step/the_project_is_tagged.dart';
import './step/the_project_is_not_tagged.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Real estate project catalog''', () {
    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets('''Overview of the active projects''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Overview of the active projects''');
        await thePublishedProjectInWithTheseLots(
            tester,
            'Los Pinos',
            'Carabayllo, Lima',
            const bdd.DataTable([
              ['code', 'price', 'status'],
              ['N-01', 45000, 'AVAILABLE'],
              ['N-02', 52000, 'AVAILABLE'],
              ['S-01', 58000, 'AVAILABLE'],
              ['S-02', 49000, 'SOLD']
            ]));
        await thePublishedProjectInWithTheseLots(
            tester,
            'Brisas del Sur',
            'Lurín, Lima',
            const bdd.DataTable([
              ['code', 'price', 'status'],
              ['B-01', 39500, 'AVAILABLE'],
              ['B-02', 39500, 'RESERVED']
            ]));
        await aBuyerIsSignedIn(tester);
        await theBuyerOpensTheProjectCatalog(tester);
        await theCatalogListsTheProjects(tester, 'Brisas del Sur, Los Pinos');
        await theProjectShowsAThumbnail(tester, 'Los Pinos');
        await theProjectShowsThePriceRange(
            tester, 'Los Pinos', 'S/ 45,000.00 – S/ 58,000.00');
        await theProjectShowsTheAvailability(
            tester, 'Los Pinos', '3 de 4 lotes disponibles (75 %)');
        await theProjectShowsThePriceRange(
            tester, 'Brisas del Sur', 'S/ 39,500.00');
        await theProjectShowsTheAvailability(
            tester, 'Brisas del Sur', '1 de 2 lotes disponibles (50 %)');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Overview of the active projects''',
          success,
        );
      }
    });
    testWidgets('''Sold-out project indicator''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Sold-out project indicator''');
        await thePublishedProjectInWithTheseLots(
            tester,
            'Los Pinos',
            'Carabayllo, Lima',
            const bdd.DataTable([
              ['code', 'price', 'status'],
              ['N-01', 45000, 'AVAILABLE']
            ]));
        await thePublishedProjectInWithTheseLots(
            tester,
            'Las Dunas',
            'Chilca, Lima',
            const bdd.DataTable([
              ['code', 'price', 'status'],
              ['A-01', 38000, 'SOLD'],
              ['A-02', 41000, 'SOLD']
            ]));
        await aBuyerIsSignedIn(tester);
        await theBuyerOpensTheProjectCatalog(tester);
        await theCatalogListsTheProjects(tester, 'Las Dunas, Los Pinos');
        await theProjectIsTagged(tester, 'Las Dunas', 'VENDIDO TOTALMENTE');
        await theProjectShowsTheAvailability(
            tester, 'Las Dunas', 'Sus 2 lotes están vendidos');
        await theProjectIsNotTagged(tester, 'Los Pinos', 'VENDIDO TOTALMENTE');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Sold-out project indicator''',
          success,
        );
      }
    });
  });
}
