import 'dart:convert';
import 'dart:io';

/// Turns the JSON results of the acceptance scenarios into a Markdown report, one row per scenario.
///
///     flutter test --tags acceptance --file-reporter json:build/acceptance/results.json
///     dart run tool/acceptance_report.dart build/acceptance/results.json > build/acceptance/report.md
///
/// Exits with 1 when a scenario failed or none ran.
void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Usage: dart run tool/acceptance_report.dart <results.json>');
    exit(64);
  }
  final suites = <int, String>{};
  final groups = <int, String>{};
  final scenarios = <int, _Scenario>{};
  for (final line in File(args.single).readAsLinesSync()) {
    if (!line.startsWith('{')) continue;
    final event = jsonDecode(line) as Map<String, dynamic>;
    switch (event['type']) {
      case 'suite':
        final suite = event['suite'] as Map<String, dynamic>;
        suites[suite['id'] as int] = suite['path'] as String? ?? '';
      case 'group':
        final group = event['group'] as Map<String, dynamic>;
        groups[group['id'] as int] = group['name'] as String? ?? '';
      case 'testStart':
        final test = event['test'] as Map<String, dynamic>;
        final groupIds = (test['groupIDs'] as List).cast<int>();
        final feature = groupIds.isEmpty ? '' : groups[groupIds.last] ?? '';
        final name = test['name'] as String;
        scenarios[test['id'] as int] = _Scenario(
          path: suites[test['suiteID'] as int] ?? '',
          feature: feature,
          name: feature.isNotEmpty && name.startsWith('$feature ') ? name.substring(feature.length + 1) : name,
          startedAt: event['time'] as int,
        );
      case 'testDone':
        final scenario = scenarios[event['testID'] as int];
        if (scenario == null) continue;
        if (event['hidden'] == true) {
          scenarios.remove(event['testID']);
          continue;
        }
        scenario
          ..result = event['skipped'] == true ? 'Skipped' : (event['result'] == 'success' ? 'Passed' : 'Failed')
          ..milliseconds = (event['time'] as int) - scenario.startedAt;
    }
  }

  final rows = scenarios.values.where((scenario) => scenario.result != null).toList()
    ..sort((a, b) => a.story.compareTo(b.story));
  final passed = rows.where((scenario) => scenario.result == 'Passed').length;
  final failed = rows.where((scenario) => scenario.result == 'Failed').length;
  final out = StringBuffer()
    ..writeln('## Acceptance results (BDD)')
    ..writeln()
    ..writeln('${rows.length} scenarios: $passed passed, $failed failed.')
    ..writeln()
    ..writeln('| Story | Feature | Scenario | Result | Time |')
    ..writeln('|---|---|---|---|---|');
  for (final scenario in rows) {
    out.writeln(
      '| ${scenario.story} | ${_cell(scenario.feature)} | ${_cell(scenario.name)} | ${scenario.result} | '
      '${(scenario.milliseconds / 1000).toStringAsFixed(1)} s |',
    );
  }
  stdout.write(out);
  if (rows.isEmpty || failed > 0) exitCode = 1;
}

String _cell(String text) => text.replaceAll('|', r'\|');

class _Scenario {
  final String path;
  final String feature;
  final String name;
  final int startedAt;
  String? result;
  int milliseconds = 0;

  _Scenario({required this.path, required this.feature, required this.name, required this.startedAt});

  /// `US-17` for `test/acceptance/us17_financing_simulation_test.dart`.
  String get story {
    final number = RegExp(r'us(\d+)_').firstMatch(path.replaceAll(r'\', '/').split('/').last)?.group(1);
    return number == null ? '-' : 'US-$number';
  }
}
