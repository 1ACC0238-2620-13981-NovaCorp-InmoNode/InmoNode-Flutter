import 'package:flutter/material.dart';
import 'package:inmonode/core/formatting/formats.dart';
import 'package:inmonode/core/widgets/message_banner.dart';
import 'package:inmonode/features/quotations/domain/quotation.dart';

/// A simulated financing: the monthly installment, its totals, its validity and the schedule (US-17, T33).
class QuotationResult extends StatelessWidget {
  final Quotation quotation;

  const QuotationResult({super.key, required this.quotation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = quotation.currency;
    String money(double amount) => Formats.money(amount, currency: currency);
    final adjusted = quotation.adjustedLastInstallment;
    final validUntil = quotation.validUntil.toLocal();
    final facts = [
      ('Precio del lote', money(quotation.lotPrice)),
      ('Cuota inicial (${Formats.percent(quotation.initialPercentage)})', money(quotation.initialPayment)),
      ('Monto financiado', money(quotation.financedAmount)),
      ('Tasa de interés anual', Formats.rate(quotation.annualInterestRate)),
      ('Intereses', money(quotation.totalInterest)),
      ('Total a pagar', money(quotation.totalToPay)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Resultado de la simulación', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cuota mensual',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                ),
                const SizedBox(height: 4),
                Text(
                  money(quotation.monthlyInstallment),
                  style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    '${quotation.termMonths} ${quotation.termMonths == 1 ? 'cuota' : 'cuotas'}',
                    if (adjusted != null) 'la última de ${money(adjusted.amount)} por redondeo',
                  ].join(', '),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (label, value) in facts)
              SizedBox(
                width: 200,
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: theme.textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(value, style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        MessageBanner.info(
          'Esta simulación es válida hasta el ${Formats.date(validUntil)} a las ${Formats.time(validUntil)}.',
        ),
        const SizedBox(height: 24),
        Text('Cronograma de cuotas', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        InstallmentSchedule(installments: quotation.installments, currency: currency),
      ],
    );
  }
}

/// The installments as a table on wide screens and as a list on phones.
class InstallmentSchedule extends StatelessWidget {
  static const double tableBreakpoint = 640;

  final List<Installment> installments;
  final String currency;

  const InstallmentSchedule({super.key, required this.installments, required this.currency});

  @override
  Widget build(BuildContext context) {
    String money(double amount) => Formats.money(amount, currency: currency);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tableBreakpoint) {
          return Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('N.º'), numeric: true),
                    DataColumn(label: Text('Vencimiento')),
                    DataColumn(label: Text('Cuota'), numeric: true),
                    DataColumn(label: Text('Capital'), numeric: true),
                    DataColumn(label: Text('Interés'), numeric: true),
                    DataColumn(label: Text('Saldo'), numeric: true),
                  ],
                  rows: [
                    for (final installment in installments)
                      DataRow(
                        cells: [
                          DataCell(Text('${installment.number}')),
                          DataCell(Text(Formats.date(installment.dueDate))),
                          DataCell(Text(money(installment.amount))),
                          DataCell(Text(money(installment.principal))),
                          DataCell(Text(money(installment.interest))),
                          DataCell(Text(money(installment.balance))),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        }
        final theme = Theme.of(context);
        return Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (index, installment) in installments.indexed) ...[
                if (index > 0) const Divider(height: 1),
                ListTile(
                  title: Row(
                    children: [
                      Expanded(child: Text('Cuota ${installment.number}')),
                      Text(money(installment.amount), style: theme.textTheme.titleSmall),
                    ],
                  ),
                  subtitle: Text(
                    'Vence el ${Formats.date(installment.dueDate)} · '
                    'Capital ${money(installment.principal)} · Interés ${money(installment.interest)} · '
                    'Saldo ${money(installment.balance)}',
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
