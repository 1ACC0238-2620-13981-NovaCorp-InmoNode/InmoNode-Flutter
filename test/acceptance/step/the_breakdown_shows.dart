import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: the breakdown shows:
Future<void> theBreakdownShows(WidgetTester tester, bdd.DataTable breakdown) async {
  for (final row in breakdown.asMaps()) {
    final concept = row['concept'] as String;
    final fact = find.ancestor(of: find.text(concept), matching: find.byType(Card)).first;
    expect(find.descendant(of: fact, matching: find.text(row['value'] as String)), findsOneWidget, reason: concept);
  }
}
