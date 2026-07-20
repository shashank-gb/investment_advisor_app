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

  Future<List<MarketIndex>> getMarketIndexes() async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return const [
        MarketIndex(name: 'NIFTY 50', value: 24150.70, change: 125.30, changePercent: 0.52),
        MarketIndex(name: 'SENSEX', value: 79842.20, change: 412.15, changePercent: 0.52),
        MarketIndex(name: 'NIFTY BANK', value: 51230.45, change: -89.20, changePercent: -0.17),
      ];
    }

    try {
      final response = await _dio.get(ApiEndpoints.marketIndexes);
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => MarketIndex.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiClient.parseError(e);
    }
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
}
