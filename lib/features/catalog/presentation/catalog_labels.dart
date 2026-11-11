import 'package:inmonode/core/formatting/formats.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog/domain/price_range.dart';
import 'package:inmonode/features/catalog/domain/project_summary.dart';

/// Texts of the catalog shared by the cards and the project page.
class CatalogLabels {
  static const String soldOut = 'Vendido totalmente';

  static String priceRange(PriceRange? range) {
    if (range == null) return 'Precios por confirmar';
    final min = Formats.money(range.min, currency: range.currency);
    if (range.min == range.max) return min;
    return '$min – ${Formats.money(range.max, currency: range.currency)}';
  }

  static String availability(ProjectSummary project) {
    final total = project.totalLots;
    if (total == 0) return 'Aún sin lotes';
    if (project.soldOut) return total == 1 ? 'Su único lote está vendido' : 'Sus $total lotes están vendidos';
    final lots = total == 1 ? 'lote disponible' : 'lotes disponibles';
    return '${project.availableLots} de $total $lots (${Formats.percent(project.availabilityPercentage)})';
  }

  static String lotStatus(LotStatus status) {
    return switch (status) {
      LotStatus.draft => 'No publicado',
      LotStatus.available => 'Disponible',
      LotStatus.blocked => 'En separación',
      LotStatus.pendingVerification => 'Pago en verificación',
      LotStatus.reserved => 'Reservado',
      LotStatus.sold => 'Vendido',
    };
  }
}
