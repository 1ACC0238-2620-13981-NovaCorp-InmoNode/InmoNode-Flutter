import 'package:flutter/material.dart';
import 'package:inmonode/core/widgets/message_banner.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_view_model.dart';

/// The answer to an action of the catalog back-office, placed above the button that asked for it so that
/// it is seen without scrolling.
class CatalogFeedbackBanner extends StatelessWidget {
  final CatalogFeedback? feedback;

  const CatalogFeedbackBanner(this.feedback, {super.key});

  @override
  Widget build(BuildContext context) {
    final current = feedback;
    if (current == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: current.isError ? MessageBanner.error(current.message) : MessageBanner.info(current.message),
    );
  }
}
