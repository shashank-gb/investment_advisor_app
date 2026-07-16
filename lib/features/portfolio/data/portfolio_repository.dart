import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../domain/portfolio_models.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepository(ref.watch(apiClientProvider));
});

/// Portfolio data sourced from BSE Star MF via backend REST API.
class PortfolioRepository {
  PortfolioRepository(this._dio);

  final Dio _dio;

  Future<PortfolioSummary> getSummary() async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return const PortfolioSummary(
        totalInvested: 250000,
        currentValue: 312450,
        totalReturns: 62450,
        returnsPercent: 24.98,
        xirr: 18.5,
      );
    }

    try {
      final response = await _dio.get(ApiEndpoints.portfolioSummary);
      return PortfolioSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  Future<List<PortfolioHolding>> getHoldings() async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return const [
        PortfolioHolding(
          fundId: 'mf1',
          fundName: 'Bluechip Growth Fund',
          amc: 'HDFC AMC',
          units: 125.432,
          investedAmount: 100000,
          currentValue: 105620,
          returns: 5620,
          returnsPercent: 5.62,
          folioNumber: '1234567890',
        ),
        PortfolioHolding(
          fundId: 'mf6',
          fundName: 'Tax Saver ELSS Fund',
          amc: 'Mirae AMC',
          units: 890.12,
          investedAmount: 75000,
          currentValue: 100350,
          returns: 25350,
          returnsPercent: 33.8,
          folioNumber: '9876543210',
        ),
        PortfolioHolding(
          fundId: 'mf3',
          fundName: 'Corporate Bond Fund',
          amc: 'ICICI AMC',
          units: 1650.0,
          investedAmount: 75000,
          currentValue: 74580,
          returns: -420,
          returnsPercent: -0.56,
          folioNumber: '5555666677',
        ),
      ];
    }

    try {
      final response = await _dio.get(ApiEndpoints.portfolio);
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => PortfolioHolding.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiClient.parseError(e);
    }
  }
}
