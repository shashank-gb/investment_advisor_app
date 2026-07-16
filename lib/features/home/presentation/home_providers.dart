import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/home_repository.dart';
import '../domain/home_models.dart';

final categoriesProvider = FutureProvider<List<FundCategory>>((ref) {
  return ref.watch(homeRepositoryProvider).getCategories();
});

final topFundsProvider = FutureProvider.family<List<MutualFund>, String>((ref, categoryId) {
  return ref.watch(homeRepositoryProvider).getTopFunds(categoryId);
});

final marketIndexesProvider = FutureProvider<List<MarketIndex>>((ref) {
  return ref.watch(homeRepositoryProvider).getMarketIndexes();
});

final blogsProvider = FutureProvider<List<ContentItem>>((ref) {
  return ref.watch(homeRepositoryProvider).getBlogs();
});

final adsProvider = FutureProvider<List<ContentItem>>((ref) {
  return ref.watch(homeRepositoryProvider).getAds();
});

final goalProvider = FutureProvider<List<ContentItem>>((ref) {
  return ref.watch(homeRepositoryProvider).getGoalBanner();
});
