import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/funds/domain/funds_models.dart';
import '../theme/app_colors.dart';

enum MutualFundCardVariant { compact, detailed }

class MutualFundCard extends StatelessWidget {
  const MutualFundCard({
    super.key,
    required this.fund,
    this.rank,
    this.variant = MutualFundCardVariant.compact,
  });

  final MutualFund fund;
  final int? rank;
  final MutualFundCardVariant variant;

  @override
  Widget build(BuildContext context) {
    if (variant == MutualFundCardVariant.compact) {
      return _CompactFundCard(fund: fund, rank: rank);
    }
    return _DetailedFundCard(fund: fund);
  }
}

class _CompactFundCard extends StatelessWidget {
  const _CompactFundCard({required this.fund, this.rank});
  final MutualFund fund;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final isPositive = fund.returns1Y >= 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/funds/${fund.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (rank != null) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fund.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      fund.amc,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${fund.nav.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${isPositive ? '+' : ''}${fund.returns1Y.toStringAsFixed(1)}% (1Y)',
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
        ),
      ),
    );
  }
}

class _DetailedFundCard extends StatelessWidget {
  const _DetailedFundCard({required this.fund});
  final MutualFund fund;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/funds/${fund.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.show_chart_rounded, color: AppColors.primary, size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fund.name,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, height: 1.2),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fund.amc,
                          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatItem(
                    label: '3Y Returns',
                    value: '${fund.returns3Y?.toStringAsFixed(1) ?? fund.returns1Y.toStringAsFixed(1)}%',
                    isPositive: true,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Risk Level', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      _RiskBar(risk: fund.riskLevel ?? 'Moderate'),
                    ],
                  ),
                  _StatItem(
                    label: 'Min Invest',
                    value: '₹${fund.minInvestment?.toInt() ?? 500}',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.support_agent, size: 20),
                      label: const Text('Connect with Advisor', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _SideAction(
                    icon: Icons.analytics_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _SideAction(
                    icon: Icons.favorite_border,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideAction extends StatelessWidget {
  const _SideAction({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A237E).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1A237E).withValues(alpha: 0.1)),
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF1A237E)),
      ),
    );
  }
}

class _RiskBar extends StatelessWidget {
  const _RiskBar({required this.risk});
  final String risk;

  @override
  Widget build(BuildContext context) {
    int activeSegments = 1;
    Color color = Colors.green;

    final r = risk.toLowerCase();
    if (r.contains('low')) {
      activeSegments = 1;
      color = Colors.green;
    } else if (r.contains('moderate')) {
      activeSegments = 2;
      color = Colors.orange;
    } else {
      activeSegments = 3;
      color = Colors.red;
    }

    return Row(
      children: List.generate(3, (index) {
        return Container(
          width: 20,
          height: 6,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            color: index < activeSegments ? color : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, this.isPositive});
  final String label;
  final String value;
  final bool? isPositive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isPositive == true ? Colors.green : Colors.black87,
          ),
        ),
      ],
    );
  }
}
