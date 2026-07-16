import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/home_models.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(apiClientProvider));
});

class HomeRepository {
  HomeRepository(this._dio);

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

    final response = await _dio.get(ApiEndpoints.fundCategories);
    final list = response.data['data'] as List<dynamic>;
    return list.map((e) => FundCategory.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<MutualFund>> getTopFunds(String categoryId) async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return _mockFunds.where((f) => f.category.toLowerCase() == categoryId).toList()
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

  Future<List<MarketIndex>> getMarketIndexes() async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return const [
        MarketIndex(name: 'NIFTY 50', value: 24150.70, change: 125.30, changePercent: 0.52),
        MarketIndex(name: 'SENSEX', value: 79842.20, change: 412.15, changePercent: 0.52),
        MarketIndex(name: 'NIFTY BANK', value: 51230.45, change: -89.20, changePercent: -0.17),
      ];
    }

    final response = await _dio.get(ApiEndpoints.marketIndexes);
    final list = response.data['data'] as List<dynamic>;
    return list.map((e) => MarketIndex.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ContentItem>> getBlogs() async {
    if (AppConfig.useMockData) {
      return const [
        ContentItem(
          id: 'b1',
          title: 'Understanding SIP: Your Path to Wealth',
          subtitle: 'Learn how small regular investments compound over time.',
          type: ContentType.blog,
        ),
        ContentItem(
          id: 'b2',
          title: 'ELSS vs PPF: Which Tax Saver Wins?',
          subtitle: 'Compare returns, lock-in, and tax benefits.',
          type: ContentType.blog,
        ),
      ];
    }

    final response = await _dio.get(ApiEndpoints.blogs);
    final list = response.data['data'] as List<dynamic>;
    return list.map((e) => ContentItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ContentItem>> getAds() async {
    if (AppConfig.useMockData) {
      return const [
        ContentItem(
          id: 'a1',
          title: 'Start SIP from ₹500/month',
          subtitle: 'Begin your investment journey today with expert guidance.',
          type: ContentType.ad,
        ),
      ];
    }

    final response = await _dio.get(ApiEndpoints.ads);
    final list = response.data['data'] as List<dynamic>;
    return list.map((e) => ContentItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ContentItem>> getGoalBanner() async {
    if (AppConfig.useMockData) {
      return const [
        ContentItem(
          id: 'g1',
          title: 'Not sure where to invest? Plan by Goal',
          subtitle: 'Begin your investment journey today with expert guidance.',
          type: ContentType.ad,
        ),
      ];
    }

    final response = await _dio.get(ApiEndpoints.ads);
    final list = response.data['data'] as List<dynamic>;
    return list.map((e) => ContentItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  static const _mockFunds = [
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
