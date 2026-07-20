import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mf_app/core/widgets/async_state_widgets.dart';
import 'package:mf_app/features/goals/domain/goal_models.dart';
import 'package:mf_app/features/goals/presentation/goals_providers.dart';

class GoalSelectionScreen extends ConsumerStatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  ConsumerState<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends ConsumerState<GoalSelectionScreen> {
  String? _selectedGoalId;
  String _riskLevel = 'MEDIUM';
  final _customGoalController = TextEditingController();

  @override
  void dispose() {
    _customGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Investment Planner',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: goalsAsync.when(
        data: (goals) => LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            final double horizontalPadding = isWide ? (constraints.maxWidth - 1000).clamp(40, double.infinity) / 2 : 20;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What are you planning for?',
                        style: TextStyle(
                          fontSize: isWide ? 32 : 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select a goal to get tailored suggestions.',
                        style: TextStyle(color: Colors.grey, fontSize: isWide ? 16 : 14),
                      ),
                      const SizedBox(height: 32),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isWide ? 6 : 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: goals.length,
                        itemBuilder: (context, index) {
                          final goal = goals[index];
                          final isSelected = _selectedGoalId == goal.id;
                          return _GoalTile(
                            goal: goal,
                            isSelected: isSelected,
                            onTap: () => setState(() => _selectedGoalId = goal.id),
                          );
                        },
                      ),
                      if (_selectedGoalId == 'others') ...[
                        const SizedBox(height: 24),
                        TextField(
                          controller: _customGoalController,
                          decoration: InputDecoration(
                            labelText: 'Define your custom goal',
                            hintText: 'e.g., European Trip, Wedding',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 48),
                      Text(
                        'How much risk can you take?',
                        style: TextStyle(fontSize: isWide ? 24 : 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      if (isWide)
                        Row(
                          children: [
                            Expanded(
                              child: _RiskCard(
                                title: 'Conservative',
                                subtitle: 'Low risk, stable returns. Capital safety.',
                                level: 'LOW',
                                isSelected: _riskLevel == 'LOW',
                                onTap: () => setState(() => _riskLevel = 'LOW'),
                                color: Colors.green,
                                icon: Icons.shield_outlined,
                                isWide: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _RiskCard(
                                title: 'Moderate',
                                subtitle: 'Medium risk. Balance growth & stability.',
                                level: 'MEDIUM',
                                isSelected: _riskLevel == 'MEDIUM',
                                onTap: () => setState(() => _riskLevel = 'MEDIUM'),
                                color: Colors.orange,
                                icon: Icons.balance_outlined,
                                isWide: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _RiskCard(
                                title: 'Aggressive',
                                subtitle: 'High risk. For long term wealth.',
                                level: 'HIGH',
                                isSelected: _riskLevel == 'HIGH',
                                onTap: () => setState(() => _riskLevel = 'HIGH'),
                                color: Colors.red,
                                icon: Icons.trending_up_rounded,
                                isWide: true,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _RiskCard(
                          title: 'Conservative',
                          subtitle: 'Low risk, stable returns. Focus on capital safety.',
                          level: 'LOW',
                          isSelected: _riskLevel == 'LOW',
                          onTap: () => setState(() => _riskLevel = 'LOW'),
                          color: Colors.green,
                          icon: Icons.shield_outlined,
                          isWide: false,
                        ),
                        const SizedBox(height: 12),
                        _RiskCard(
                          title: 'Moderate',
                          subtitle: 'Medium risk. Balance between growth and stability.',
                          level: 'MEDIUM',
                          isSelected: _riskLevel == 'MEDIUM',
                          onTap: () => setState(() => _riskLevel = 'MEDIUM'),
                          color: Colors.orange,
                          icon: Icons.balance_outlined,
                          isWide: false,
                        ),
                        const SizedBox(height: 12),
                        _RiskCard(
                          title: 'Aggressive',
                          subtitle: 'High risk, high potential. For long term wealth.',
                          level: 'HIGH',
                          isSelected: _riskLevel == 'HIGH',
                          onTap: () => setState(() => _riskLevel = 'HIGH'),
                          color: Colors.red,
                          icon: Icons.trending_up_rounded,
                          isWide: false,
                        ),
                      ],
                      const SizedBox(height: 64),
                      Center(
                        child: SizedBox(
                          width: isWide ? 400 : double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _selectedGoalId == null ? null : _handleNavigation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A237E),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: const Color(0xFF1A237E).withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text(
                              'Get Recommendations',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        loading: () => const LoadingView(message: 'Exploring goals...'),
        error: (e, _) => ErrorView(
          message: 'Failed to load options',
          onRetry: () => ref.invalidate(goalsListProvider),
        ),
      ),
    );
  }

  void _handleNavigation() {
    final goals = (ref.read(goalsListProvider)).value!;
    final goal = goals.firstWhere((g) => g.id == _selectedGoalId);

    // If "Others" is selected, use the custom name if provided
    final finalGoal = _selectedGoalId == 'others' && _customGoalController.text.isNotEmpty
        ? InvestmentGoal(
            id: goal.id,
            title: _customGoalController.text.toUpperCase(),
            description: goal.description,
            iconData: goal.iconData,
            colorHex: goal.colorHex,
            categoryIds: goal.categoryIds,
          )
        : goal;

    context.push(
      '/home/goals/${finalGoal.id}',
      extra: (goal: finalGoal, risk: _riskLevel),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  final InvestmentGoal goal;
  final bool isSelected;
  final VoidCallback onTap;

  IconData _getIcon(String name) {
    switch (name) {
      case 'home': return Icons.home_rounded;
      case 'directions_car': return Icons.directions_car_rounded;
      case 'person': return Icons.person_rounded;
      case 'favorite': return Icons.favorite_rounded;
      case 'school': return Icons.school_rounded;
      case 'flight': return Icons.flight_rounded;
      case 'rocket_launch': return Icons.rocket_launch_rounded;
      case 'add_alert': return Icons.add_alert_rounded;
      case 'more_horiz': return Icons.more_horiz_rounded;
      default: return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? const Color(0xFF1A237E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isSelected ? const Color(0xFF1A237E).withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(goal.iconData),
              color: isSelected ? Colors.white : Colors.black87,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              goal.title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({
    required this.title,
    required this.subtitle,
    required this.level,
    required this.isSelected,
    required this.onTap,
    required this.color,
    required this.icon,
    required this.isWide,
  });

  final String title;
  final String subtitle;
  final String level;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final IconData icon;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        height: isWide ? 180 : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: isWide 
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3),
                    textAlign: TextAlign.center,
                  ),
                  if (isSelected) ...[
                    const Spacer(),
                    Icon(Icons.check_circle, color: color, size: 20),
                  ],
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isSelected ? color : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: color, size: 24),
                ],
              ),
      ),
    );
  }
}
