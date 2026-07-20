import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/funds_models.dart';

final fundsRepositoryProvider = Provider<FundsRepository>((ref) {
  return FundsRepository(ref.watch(apiClientProvider));
});

class FundsRepository {
  FundsRepository(this._dio);

  final Dio _dio;

  Future<List<FundCategory>> getCategories() async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return const [
        FundCategory(id: 'equity', name: 'Equity', description: 'Long-term growth'),
        FundCategory(id: 'debt', name: 'Debt', description: 'Stable returns'),
        FundCategory(id: 'hybrid', name: 'Hybrid', description: 'Balanced approach'),
        FundCategory(id: 'elss', name: 'ELSS', description: 'Tax saving funds'),
        FundCategory(id: 'index', name: 'Index', description: 'Market tracking'),
      ];
    }

    try {
      final response = await _dio.get(ApiEndpoints.fundCategories);
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => FundCategory.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  Future<List<MutualFund>> getTopFunds(String categoryId) async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return _allMockFunds.where((f) => f.category.toLowerCase() == categoryId).toList()
        ..sort((a, b) => b.returns1Y.compareTo(a.returns1Y));
    }

    try {
      final response = await _dio.get(
        ApiEndpoints.topFunds,
        queryParameters: {'category': categoryId, 'limit': 10},
      );
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => MutualFund.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  Future<List<MutualFund>> getFundsByGoal(String goalId, {String? riskProfile}) async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      // In a real app, we'd fetch the goal details first or have an endpoint that takes goalId + riskProfile
      // For mock, we'll just filter our global mock list
      var filteredFunds = _allMockFunds;

      if (riskProfile != null) {
        switch (riskProfile.toLowerCase()) {
          case 'low':
            filteredFunds = filteredFunds.where((f) => 
              f.riskLevel?.toLowerCase().contains('low') == true || 
              f.category == 'debt'
            ).toList();
            break;
          case 'medium':
            filteredFunds = filteredFunds.where((f) => 
              f.riskLevel?.toLowerCase().contains('moderate') == true || 
              f.category == 'hybrid'
            ).toList();
            break;
          case 'high':
            filteredFunds = filteredFunds.where((f) => 
              f.riskLevel?.toLowerCase().contains('high') == true || 
              f.category == 'equity' || f.category == 'index'
            ).toList();
            break;
        }
      }

      return filteredFunds;
    }

    try {
      final response = await _dio.get(
        ApiEndpoints.goalFunds,
        queryParameters: {'goal_id': goalId, 'risk': riskProfile},
      );
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => MutualFund.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  Future<FundDetail> getFundDetail(String fundId) async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return _getMockDetail(fundId);
    }

    try {
      final response = await _dio.get(
        ApiEndpoints.fundDetail,
        queryParameters: {'id': fundId},
      );
      return FundDetail.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  FundDetail _getMockDetail(String id) {
    final fund = _allMockFunds.firstWhere((f) => f.id == id, orElse: () => _allMockFunds.first);

    return FundDetail(
      fund: fund,
      aum: '24,100 Cr',
      expenseRatio: '1.10%',
      exitLoad: '1.0% if redeemed before 1 year.',
      minSip: '100',
      holdings: const [
        PortfolioHolding(name: 'HDFC Bank', companyName: 'Financial', weightage: 9.5),
        PortfolioHolding(name: 'ICICI Bank', companyName: 'Financial', weightage: 8.2),
        PortfolioHolding(name: 'RIL', companyName: 'Energy', weightage: 7.1),
        PortfolioHolding(name: 'Infosys', companyName: 'Technology', weightage: 5.4),
        PortfolioHolding(name: 'TCS', companyName: 'Technology', weightage: 4.8),
        PortfolioHolding(name: 'Airtel', companyName: 'Telecom', weightage: 3.2),
      ],
      performanceChart: List.generate(30, (index) {
        return ChartPoint(
          date: DateTime.now().subtract(Duration(days: 30 - index)),
          value: 50.0 + (index * 0.5) + (index % 3 == 0 ? 2.0 : -1.0),
        );
      }),
    );
  }

  static const _allMockFunds = [
    MutualFund(
      id: 'mf1',
      name: 'Bluechip Growth Fund',
      amc: 'HDFC AMC',
      category: 'equity',
      nav: 842.35,
      returns1Y: 22.4,
      returns3Y: 18.2,
      riskLevel: 'Very High',
      minInvestment: 500,
    ),
    MutualFund(
      id: 'mf2',
      name: 'Midcap Opportunities',
      amc: 'Axis AMC',
      category: 'equity',
      nav: 156.80,
      returns1Y: 28.1,
      returns3Y: 21.5,
      riskLevel: 'Very High',
      minInvestment: 500,
    ),
    MutualFund(
      id: 'mf3',
      name: 'Corporate Bond Fund',
      amc: 'ICICI AMC',
      category: 'debt',
      nav: 45.20,
      returns1Y: 8.2,
      returns3Y: 7.5,
      riskLevel: 'Moderate',
      minInvestment: 1000,
    ),
    MutualFund(
      id: 'mf4',
      name: 'Short Duration Fund',
      amc: 'SBI AMC',
      category: 'debt',
      nav: 32.15,
      returns1Y: 7.1,
      returns3Y: 6.8,
      riskLevel: 'Low to Moderate',
      minInvestment: 1000,
    ),
    MutualFund(
      id: 'mf5',
      name: 'Balanced Advantage Fund',
      amc: 'Kotak AMC',
      category: 'hybrid',
      nav: 78.90,
      returns1Y: 14.5,
      returns3Y: 12.3,
      riskLevel: 'Moderately High',
      minInvestment: 500,
    ),
    MutualFund(
      id: 'mf6',
      name: 'Tax Saver ELSS Fund',
      amc: 'Mirae AMC',
      category: 'elss',
      nav: 112.45,
      returns1Y: 19.8,
      returns3Y: 16.2,
      riskLevel: 'Very High',
      minInvestment: 500,
    ),
    MutualFund(
      id: 'mf7',
      name: 'Nifty 50 Index Fund',
      amc: 'UTI AMC',
      category: 'index',
      nav: 198.30,
      returns1Y: 20.1,
      returns3Y: 17.0,
      riskLevel: 'Very High',
      minInvestment: 500,
    ),
  ];
}
