/// Availability of a lot. A reservation first blocks the lot, then waits for the payment to be verified and
/// reserves it; the sale closes it.
enum LotStatus {
  /// Registered but not published yet (US-52); buyers should never see it.
  draft('DRAFT'),
  available('AVAILABLE'),
  blocked('BLOCKED'),
  pendingVerification('PENDING_VERIFICATION'),
  reserved('RESERVED'),
  sold('SOLD');

  final String apiName;

  const LotStatus(this.apiName);

  static LotStatus fromApiName(String name) {
    for (final status in values) {
      if (status.apiName == name) return status;
    }
    throw FormatException('Unknown lot status: $name');
  }
}

/// A lot of a project, with its measures in meters and its price.
class Lot {
  final int id;
  final String code;
  final double area;

  /// Front and depth are only given for regular lots.
  final double? front;
  final double? depth;
  final double price;
  final String currency;
  final LotStatus status;

  const Lot({
    required this.id,
    required this.code,
    required this.area,
    this.front,
    this.depth,
    required this.price,
    required this.currency,
    required this.status,
  });

  bool get isAvailable => status == LotStatus.available;
}
