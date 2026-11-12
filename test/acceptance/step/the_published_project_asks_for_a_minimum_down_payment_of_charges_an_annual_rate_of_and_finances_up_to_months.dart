import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/catalog/domain/financing_rules.dart';
import 'package:inmonode/features/catalog_admin/domain/project_status.dart';

import '../support/world.dart';

/// Usage: the published project {'Los Pinos'} asks for a minimum down payment of {10} %, charges an annual rate of {12.5} % and finances up to {60} months
Future<void> thePublishedProjectAsksForAMinimumDownPaymentOfChargesAnAnnualRateOfAndFinancesUpToMonths(
  WidgetTester tester,
  String name,
  num minimumDownPaymentPercentage,
  num annualInterestRate,
  num maxTermMonths,
) async {
  World.current.catalog.addProject(
    name: name,
    status: ProjectStatus.published,
    rules: FinancingRules(
      minDownPaymentPercentage: minimumDownPaymentPercentage.toDouble(),
      annualInterestRate: annualInterestRate.toDouble(),
      maxTermMonths: maxTermMonths.toInt(),
      lateFeeRate: 1.5,
    ),
  );
}
