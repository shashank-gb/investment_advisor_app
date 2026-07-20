import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_state_widgets.dart';
import '../../../core/widgets/mutual_fund_card.dart';
import 'package:mf_app/features/funds/domain/funds_models.dart';
import 'watchlist_providers.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  TabController? _tabController;

  @override
  void dispose() {
    _searchController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(watchlistGroupsProvider);
    final searchAsync = _searchQuery.length >= 2
        ? ref.watch(fundSearchProvider(_searchQuery))
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search mutual funds...',
              leading: const Icon(Icons.search),
              trailing: _searchQuery.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      ),
                    ]
                  : null,
              onChanged: _onSearchChanged,
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(AppColors.surface),
              side: WidgetStateProperty.all(
                const BorderSide(color: AppColors.divider),
              ),
            ),
          ),
          if (_searchQuery.length >= 2)
            Expanded(child: _SearchResults(searchAsync: searchAsync))
          else
            Expanded(
              child: groupsAsync.when(
                data: (groups) {
                  if (groups.isEmpty) {
                    return const EmptyStateView(
                      icon: Icons.bookmark_border,
                      title: 'No watchlists yet',
                      subtitle: 'Create a watchlist to track funds you are interested in.',
                    );
                  }

                  _tabController ??= TabController(length: groups.length, vsync: this);
                  if (_tabController!.length != groups.length) {
                    _tabController!.dispose();
                    _tabController = TabController(length: groups.length, vsync: this);
                  }

                  return Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primary,
                        tabs: groups
                            .map(
                              (g) => Tab(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(g.name),
                                    if (g.fundCount > 0) ...[
                                      const SizedBox(width: 6),
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor:
                                            AppColors.primary.withValues(alpha: 0.12),
                                        child: Text(
                                          '${g.fundCount}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: groups
                              .map((g) => _WatchlistTab(groupId: g.id))
                              .toList(),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const LoadingView(message: 'Loading watchlists...'),
                error: (e, _) => ErrorView(
                  message: 'Could not load watchlists',
                  onRetry: () => ref.invalidate(watchlistGroupsProvider),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.searchAsync});

  final AsyncValue<List<MutualFund>>? searchAsync;

  @override
  Widget build(BuildContext context) {
    if (searchAsync == null) return const SizedBox.shrink();

    return searchAsync!.when(
      data: (funds) {
        if (funds.isEmpty) {
          return const EmptyStateView(
            icon: Icons.search_off,
            title: 'No funds found',
            subtitle: 'Try a different search term.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: funds.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MutualFundCard(fund: funds[index]),
          ),
        );
      },
      loading: () => const LoadingView(message: 'Searching...'),
      error: (e, _) => ErrorView(message: 'Search failed'),
    );
  }
}

class _WatchlistTab extends ConsumerWidget {
  const _WatchlistTab({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fundsAsync = ref.watch(watchlistFundsProvider(groupId));

    return fundsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const EmptyStateView(
            icon: Icons.bookmark_add_outlined,
            title: 'This watchlist is empty',
            subtitle: 'Search and add funds to track them here.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MutualFundCard(fund: items[index].fund),
          ),
        );
      },
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(
        message: 'Could not load funds',
        onRetry: () => ref.invalidate(watchlistFundsProvider(groupId)),
      ),
    );
  }
}

// Deleted _FundListTile since we use MutualFundCard now
