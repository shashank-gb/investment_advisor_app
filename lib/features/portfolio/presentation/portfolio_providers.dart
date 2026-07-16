import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/portfolio_repository.dart';
import '../domain/portfolio_models.dart';

final portfolioSummaryProvider = FutureProvider<PortfolioSummary>((ref) {
  return ref.watch(portfolioRepositoryProvider).getSummary();
});

final portfolioHoldingsProvider = FutureProvider<List<PortfolioHolding>>((ref) {
  return ref.watch(portfolioRepositoryProvider).getHoldings();
});
