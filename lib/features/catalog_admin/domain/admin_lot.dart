import 'package:inmonode/features/catalog/domain/lot.dart';

/// A lot of the project being administered, drafts included.
class AdminLot {
  final int id;
  final String code;
  final String stageName;
  final double area;
  final double price;
  final String currency;
  final LotStatus status;

  const AdminLot({
    required this.id,
    required this.code,
    required this.stageName,
    required this.area,
    required this.price,
    required this.currency,
    required this.status,
  });

  /// Registered but not offered to buyers yet (US-52); only a draft can be published (US-53).
  bool get isDraft => status == LotStatus.draft;
}
