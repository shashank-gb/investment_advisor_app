import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../funds/data/funds_repository.dart';
import '../../funds/domain/funds_models.dart';
import '../data/goals_repository.dart';
import '../domain/goal_models.dart';

class GoalFundsArgs extends Equatable {
  final String goalId;
  final String? riskProfile;

  const GoalFundsArgs({required this.goalId, this.riskProfile});

  @override
  List<Object?> get props => [goalId, riskProfile];
}

final goalsListProvider = FutureProvider<List<InvestmentGoal>>((ref) {
  return ref.watch(goalsRepositoryProvider).getGoals();
});

final goalFundsProvider = FutureProvider.family<List<MutualFund>, GoalFundsArgs>((ref, args) {
  return ref.watch(fundsRepositoryProvider).getFundsByGoal(args.goalId, riskProfile: args.riskProfile);
});
