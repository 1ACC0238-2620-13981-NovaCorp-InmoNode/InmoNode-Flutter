import 'package:intl/intl.dart';

/// Amounts, percentages and areas as the buyer reads them in Peru: `S/ 45,000.00`, `66.7 %`, `120 m²`.
///
/// `intl` has no `es_PE` data and its `es` fallback writes `45.000,00`, so the Latin American Spanish
/// symbols are used instead.
class Formats {
  static const String _locale = 'es_419';

  static final NumberFormat _soles = NumberFormat.currency(locale: _locale, symbol: 'S/ ', decimalDigits: 2);
  static final NumberFormat _upToOneDecimal = NumberFormat('#,##0.#', _locale);
  static final NumberFormat _upToTwoDecimals = NumberFormat('#,##0.##', _locale);
  static final DateFormat _date = DateFormat('dd/MM/yyyy');
  static final DateFormat _time = DateFormat('HH:mm');
  static final RegExp _amount = RegExp(r'^\d+(\.\d{1,2})?$');

  /// An amount in soles (PEN), the currency of every price of the Web Services.
  static String money(num amount, {String currency = 'PEN'}) {
    if (currency == 'PEN') return _soles.format(amount);
    return NumberFormat.currency(locale: _locale, name: currency, symbol: '$currency ').format(amount);
  }

  static String percent(num value) => '${_upToOneDecimal.format(value)} %';

  /// An interest rate, which keeps its second decimal: `12.68 %`.
  static String rate(num value) => '${_upToTwoDecimals.format(value)} %';

  static String area(num squareMeters) => '${_upToTwoDecimals.format(squareMeters)} m²';

  static String meters(num meters) => '${_upToTwoDecimals.format(meters)} m';

  static String date(DateTime date) => _date.format(date);

  static String time(DateTime time) => _time.format(time);

  /// Reads an amount typed by the buyer, such as `4500`, `4,500.50` or `S/ 4500`. Commas only separate
  /// thousands, as in [money]; anything else, or more than two decimals, gives null.
  static double? parseAmount(String text) {
    final digits = text.replaceAll('S/', '').replaceAll(',', '').replaceAll(' ', '').trim();
    if (!_amount.hasMatch(digits)) return null;
    return double.parse(digits);
  }
}
