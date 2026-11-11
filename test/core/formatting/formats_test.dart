import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/core/formatting/formats.dart';

void main() {
  test('writes soles with thousands separated by commas, as in Peru', () {
    expect(Formats.money(45000), 'S/ 45,000.00');
    expect(Formats.money(1234567.5), 'S/ 1,234,567.50');
  });

  test('writes percentages with at most one decimal', () {
    expect(Formats.percent(66.67), '66.7 %');
    expect(Formats.percent(100), '100 %');
    expect(Formats.percent(12.5), '12.5 %');
  });

  test('writes areas and lengths in meters', () {
    expect(Formats.area(120), '120 m²');
    expect(Formats.area(98.75), '98.75 m²');
    expect(Formats.meters(8), '8 m');
  });
}
