import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mf_app/features/funds/domain/funds_models.dart';
import 'package:mf_app/features/watchlist/data/watchlist_repository.dart';
import 'package:mf_app/features/watchlist/domain/watchlist_models.dart';

final watchlistGroupsProvider = FutureProvider<List<WatchlistGroup>>((ref) {
  return ref.watch(watchlistRepositoryProvider).getGroups();
});

final watchlistFundsProvider =
    FutureProvider.family<List<WatchlistFund>, String>((ref, groupId) {
  return ref.watch(watchlistRepositoryProvider).getFundsForGroup(groupId);
});

final fundSearchProvider =
    FutureProvider.family<List<MutualFund>, String>((ref, query) {
  return ref.watch(watchlistRepositoryProvider).searchFunds(query);
});
