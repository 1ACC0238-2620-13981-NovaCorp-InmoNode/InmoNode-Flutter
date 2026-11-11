import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/catalog/domain/project_summary.dart';
import 'package:inmonode/features/catalog/presentation/project_card.dart';

import '../catalog_fakes.dart';

void main() {
  Future<void> pumpCard(WidgetTester tester, ProjectSummary project, {VoidCallback? onTap}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: ProjectCard(project: project, onTap: onTap ?? () {}),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the price range and the available lots of a project with stock', (tester) async {
    await pumpCard(tester, testSummary(totalLots: 30, availabilityPercentage: 40));

    expect(find.text('Villa del Sol'), findsOneWidget);
    expect(find.text('Carabayllo, Lima'), findsOneWidget);
    expect(find.text('S/ 35,000.00 – S/ 80,000.00'), findsOneWidget);
    expect(find.text('12 de 30 lotes disponibles (40 %)'), findsOneWidget);
    expect(find.text('VENDIDO TOTALMENTE'), findsNothing);
    final bar = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
    expect(bar.value, 0.4);
  });

  testWidgets('keeps a sold-out project visible with the "Vendido totalmente" label', (tester) async {
    var opened = false;
    await pumpCard(tester, soldOutSummary(), onTap: () => opened = true);

    expect(find.text('Los Olivos II'), findsOneWidget);
    expect(find.text('VENDIDO TOTALMENTE'), findsOneWidget);
    expect(find.text('Sus 12 lotes están vendidos'), findsOneWidget);

    await tester.tap(find.text('Los Olivos II'));
    expect(opened, isTrue);
  });

  testWidgets('counts a single lot in singular', (tester) async {
    await pumpCard(tester, testSummary(totalLots: 1, availabilityPercentage: 100));

    expect(find.text('1 de 1 lote disponible (100 %)'), findsOneWidget);
  });

  testWidgets('tells when the prices are not set yet', (tester) async {
    await pumpCard(tester, testSummary(totalLots: 0, availabilityPercentage: 0, priceRange: null));

    expect(find.text('Precios por confirmar'), findsOneWidget);
    expect(find.text('Aún sin lotes'), findsOneWidget);
  });
}
