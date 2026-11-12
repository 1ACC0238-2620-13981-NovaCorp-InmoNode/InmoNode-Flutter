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

  test('keeps the second decimal of interest rates', () {
    expect(Formats.rate(12.68), '12.68 %');
    expect(Formats.rate(12.5), '12.5 %');
    expect(Formats.rate(10), '10 %');
  });

  test('writes dates as day, month and year', () {
    expect(Formats.date(DateTime(2027, 2, 1)), '01/02/2027');
    expect(Formats.time(DateTime(2027, 2, 1, 18, 5)), '18:05');
  });

  test('reads the amounts the buyer types', () {
    expect(Formats.parseAmount('4500'), 4500);
    expect(Formats.parseAmount('4,500.50'), 4500.5);
    expect(Formats.parseAmount(' S/ 4500.5 '), 4500.5);
    expect(Formats.parseAmount('4500.555'), isNull);
    expect(Formats.parseAmount('4.500,00'), isNull);
    expect(Formats.parseAmount(''), isNull);
  });

  test('writes areas and lengths in meters', () {
    expect(Formats.area(120), '120 m²');
    expect(Formats.area(98.75), '98.75 m²');
    expect(Formats.meters(8), '8 m');
  });
}
