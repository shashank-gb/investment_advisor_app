import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'package:mf_app/features/funds/domain/funds_models.dart';
import '../domain/watchlist_models.dart';

final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  return WatchlistRepository(ref.watch(apiClientProvider));
});

class WatchlistRepository {
  WatchlistRepository(this._dio);

  final Dio _dio;

  Future<List<WatchlistGroup>> getGroups() async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return const [
        WatchlistGroup(id: 'wl1', name: 'My Picks', fundCount: 3),
        WatchlistGroup(id: 'wl2', name: 'Tax Saving', fundCount: 2),
        WatchlistGroup(id: 'wl3', name: 'Retirement', fundCount: 1),
      ];
    }

    try {
      final response = await _dio.get(ApiEndpoints.watchlistGroups);
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => WatchlistGroup.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  Future<List<WatchlistFund>> getFundsForGroup(String groupId) async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return _mockWatchlistFunds.where((f) => f.groupId == groupId).toList();
    }

    try {
      final response = await _dio.get(
        ApiEndpoints.watchlistFunds,
        queryParameters: {'group_id': groupId},
      );
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => WatchlistFund.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  Future<List<MutualFund>> searchFunds(String query) async {
    if (query.trim().length < 2) return [];

    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final lower = query.toLowerCase();
      return _allFunds
          .where(
            (f) =>
                f.name.toLowerCase().contains(lower) ||
                f.amc.toLowerCase().contains(lower) ||
                f.category.toLowerCase().contains(lower),
          )
          .toList();
    }

    try {
      final response = await _dio.get(
        ApiEndpoints.fundSearch,
        queryParameters: {'q': query, 'limit': 20},
      );
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => MutualFund.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  static const _allFunds = [
    MutualFund(
      id: 'mf1',
      name: 'Bluechip Growth Fund',
      amc: 'HDFC AMC',
      category: 'equity',
      nav: 842.35,
      returns1Y: 22.4,
    ),
    MutualFund(
      id: 'mf2',
      name: 'Midcap Opportunities',
      amc: 'Axis AMC',
      category: 'equity',
      nav: 156.80,
      returns1Y: 28.1,
    ),
    MutualFund(
      id: 'mf3',
      name: 'Corporate Bond Fund',
      amc: 'ICICI AMC',
      category: 'debt',
      nav: 45.20,
      returns1Y: 8.2,
    ),
    MutualFund(
      id: 'mf6',
      name: 'Tax Saver ELSS Fund',
      amc: 'Mirae AMC',
      category: 'elss',
      nav: 112.45,
      returns1Y: 19.8,
    ),
    MutualFund(
      id: 'mf7',
      name: 'Nifty 50 Index Fund',
      amc: 'UTI AMC',
      category: 'index',
      nav: 198.30,
      returns1Y: 20.1,
    ),
    MutualFund(
      id: 'mf8',
      name: 'Large & Mid Cap Fund',
      amc: 'Parag Parikh AMC',
      category: 'equity',
      nav: 67.90,
      returns1Y: 24.3,
    ),
  ];

  static final _mockWatchlistFunds = [
    WatchlistFund(groupId: 'wl1', fund: _allFunds[0]),
    WatchlistFund(groupId: 'wl1', fund: _allFunds[1]),
    WatchlistFund(groupId: 'wl1', fund: _allFunds[4]),
    WatchlistFund(groupId: 'wl2', fund: _allFunds[3]),
    WatchlistFund(groupId: 'wl2', fund: _allFunds[4]),
    WatchlistFund(groupId: 'wl3', fund: _allFunds[5]),
  ];
}
