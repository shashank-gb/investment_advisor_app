import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mf_app/core/widgets/async_state_widgets.dart';
import 'package:mf_app/core/widgets/mutual_fund_card.dart';
import 'package:mf_app/features/goals/domain/goal_models.dart';
import 'package:mf_app/features/goals/presentation/goals_providers.dart';

class GoalFundsScreen extends ConsumerWidget {
  const GoalFundsScreen({
    super.key,
    required this.goalId,
    required this.risk,
    this.goal,
  });

  final String goalId;
  final String risk;
  final InvestmentGoal? goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fundsAsync = ref.watch(goalFundsProvider(GoalFundsArgs(goalId: goalId, riskProfile: risk)));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          goal?.title ?? 'Personalized Funds',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended for ${goal?.title.toLowerCase() ?? "your objective"}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _FilterChip(label: risk, icon: Icons.speed_rounded),
                    const SizedBox(width: 8),
                    const _FilterChip(label: 'Curated for you', icon: Icons.auto_awesome_outlined),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: fundsAsync.when(
              data: (funds) => funds.isEmpty
                  ? const Center(child: Text('No funds found matching your criteria.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: funds.length,
                      itemBuilder: (context, index) => MutualFundCard(
                        fund: funds[index],
                        variant: MutualFundCardVariant.detailed,
                      ),
                    ),
              loading: () => const LoadingView(message: 'Curating your portfolio...'),
              error: (e, _) => ErrorView(
                message: 'Could not load suggestions',
                onRetry: () => ref.invalidate(goalFundsProvider(GoalFundsArgs(goalId: goalId, riskProfile: risk))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF1A237E).withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF1A237E)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1A237E)),
          ),
        ],
      ),
    );
  }
}
