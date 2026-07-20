import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/goal_models.dart';

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return GoalsRepository(ref.watch(apiClientProvider));
});

class GoalsRepository {
  GoalsRepository(this._dio);

  final Dio _dio;

  Future<List<InvestmentGoal>> getGoals() async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return _mockGoals;
    }

    try {
      final response = await _dio.get(ApiEndpoints.goalsList);
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => InvestmentGoal.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  static const _mockGoals = [
    InvestmentGoal(
      id: 'house',
      title: 'HOUSE',
      description: 'Save for your dream home.',
      iconData: 'home',
      colorHex: '0xFF1A237E',
      categoryIds: ['equity', 'hybrid', 'debt'],
    ),
    InvestmentGoal(
      id: 'car',
      title: 'CAR',
      description: 'Plan for your next vehicle.',
      iconData: 'directions_car',
      colorHex: '0xFF455A64',
      categoryIds: ['hybrid', 'debt'],
    ),
    InvestmentGoal(
      id: 'retirement',
      title: 'RETIREMENT',
      description: 'Build post-retirement corpus.',
      iconData: 'person',
      colorHex: '0xFF1B5E20',
      categoryIds: ['equity', 'hybrid'],
    ),
    InvestmentGoal(
      id: 'wedding',
      title: 'WEDDING',
      description: 'Secure your big day.',
      iconData: 'favorite',
      colorHex: '0xFFAD1457',
      categoryIds: ['hybrid', 'debt'],
    ),
    InvestmentGoal(
      id: 'education',
      title: 'EDUCATION',
      description: 'Child\'s future education.',
      iconData: 'school',
      colorHex: '0xFF0D47A1',
      categoryIds: ['equity', 'elss'],
    ),
    InvestmentGoal(
      id: 'vacation',
      title: 'VACATION',
      description: 'Save for world travel.',
      iconData: 'flight',
      colorHex: '0xFF00796B',
      categoryIds: ['debt', 'hybrid'],
    ),
    InvestmentGoal(
      id: 'startup',
      title: 'STARTUP',
      description: 'Capital for your business.',
      iconData: 'rocket_launch',
      colorHex: '0xFFE65100',
      categoryIds: ['equity', 'index'],
    ),
    InvestmentGoal(
      id: 'emergency',
      title: 'EMERGENCY',
      description: 'Safety net for surprises.',
      iconData: 'add_alert',
      colorHex: '0xFFC62828',
      categoryIds: ['debt'],
    ),
    InvestmentGoal(
      id: 'others',
      title: 'OTHERS',
      description: 'Custom financial objective.',
      iconData: 'more_horiz',
      colorHex: '0xFF455A64',
      categoryIds: ['equity', 'hybrid', 'debt'],
    ),
  ];
}
