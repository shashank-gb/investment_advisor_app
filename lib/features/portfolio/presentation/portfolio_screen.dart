import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_state_widgets.dart';
import '../domain/portfolio_models.dart';
import 'portfolio_providers.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(portfolioSummaryProvider);
    final holdingsAsync = ref.watch(portfolioHoldingsProvider);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(portfolioSummaryProvider);
          ref.invalidate(portfolioHoldingsProvider);
        },
        child: holdingsAsync.when(
          data: (holdings) {
            if (holdings.isEmpty) {
              return const EmptyStateView(
                icon: Icons.pie_chart_outline,
                title: 'No investments yet',
                subtitle: 'Start a SIP or lump sum investment to build your portfolio.',
              );
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: summaryAsync.when(
                    data: (summary) => _SummaryCard(summary: summary, currency: currency),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: LinearProgressIndicator(),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        Text(
                          'Your Holdings',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'BSE Star MF',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: _HoldingCard(holding: holdings[index], currency: currency),
                    ),
                    childCount: holdings.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
          loading: () => const LoadingView(message: 'Fetching your portfolio...'),
          error: (e, _) => ErrorView(
            message: 'Could not load portfolio from BSE Star MF',
            onRetry: () {
              ref.invalidate(portfolioSummaryProvider);
              ref.invalidate(portfolioHoldingsProvider);
            },
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.currency});

  final PortfolioSummary summary;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final isPositive = summary.totalReturns >= 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Value',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            currency.format(summary.currentValue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SummaryMetric(
                label: 'Invested',
                value: currency.format(summary.totalInvested),
              ),
              _SummaryMetric(
                label: 'Returns',
                value: '${isPositive ? '+' : ''}${currency.format(summary.totalReturns)}',
                valueColor: isPositive ? AppColors.accent : AppColors.negative,
              ),
              if (summary.xirr != null)
                _SummaryMetric(
                  label: 'XIRR',
                  value: '${summary.xirr!.toStringAsFixed(1)}%',
                  valueColor: AppColors.accent,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoldingCard extends StatelessWidget {
  const _HoldingCard({required this.holding, required this.currency});

  final PortfolioHolding holding;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final isPositive = holding.returns >= 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/funds/${holding.fundId}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holding.fundName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        holding.amc,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currency.format(holding.currentValue),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${isPositive ? '+' : ''}${holding.returnsPercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: isPositive ? AppColors.positive : AppColors.negative,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                _DetailChip(label: 'Units', value: holding.units.toStringAsFixed(3)),
                const SizedBox(width: 12),
                _DetailChip(label: 'Invested', value: currency.format(holding.investedAmount)),
                if (holding.folioNumber != null) ...[
                  const Spacer(),
                  Text(
                    'Folio: ${holding.folioNumber}',
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ));
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
