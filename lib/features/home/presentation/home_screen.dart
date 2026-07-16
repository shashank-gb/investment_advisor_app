import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_state_widgets.dart';
import '../domain/home_models.dart';
import 'home_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'equity';

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final indexesAsync = ref.watch(marketIndexesProvider);
    final blogsAsync = ref.watch(blogsProvider);
    final adsAsync = ref.watch(adsProvider);
    final fundsAsync = ref.watch(topFundsProvider(_selectedCategory));
    final goalBannerAsync = ref.watch(goalProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(categoriesProvider);
        ref.invalidate(marketIndexesProvider);
        ref.invalidate(blogsProvider);
        ref.invalidate(adsProvider);
        ref.invalidate(topFundsProvider(_selectedCategory));
        ref.invalidate(goalProvider);
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('Home'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: indexesAsync.when(
              data: (indexes) => _MarketIndexesStrip(indexes: indexes),
              loading: () => const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          SliverToBoxAdapter(
            child: adsAsync.when(
              data: (ads) => ads.isEmpty ? const SizedBox.shrink() : _AdsCarousel(ads: ads),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Top Performing Funds',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: categoriesAsync.when(
              data: (categories) => _CategoryChips(
                categories: categories,
                selected: _selectedCategory,
                onSelected: (id) => setState(() => _selectedCategory = id),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Failed to load categories'),
              ),
            ),
          ),
          fundsAsync.when(
            data: (funds) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: EdgeInsets.fromLTRB(16, index == 0 ? 8 : 4, 16, 4),
                  child: _FundCard(fund: funds[index], rank: index + 1),
                ),
                childCount: funds.length,
              ),
            ),
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: LoadingView(message: 'Loading top funds...'),
            ),
            error: (e, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: ErrorView(
                message: 'Could not load funds',
                onRetry: () => ref.invalidate(topFundsProvider(_selectedCategory)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: goalBannerAsync.when(
              data: (goal) => goal.isEmpty ? const SizedBox.shrink() : _GoalCard(goalContent: goal[0]),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Learn & Grow',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          blogsAsync.when(
            data: (blogs) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _BlogCard(item: blogs[index]),
                ),
                childCount: blogs.length,
              ),
            ),
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _MarketIndexesStrip extends StatelessWidget {
  const _MarketIndexesStrip({required this.indexes});

  final List<MarketIndex> indexes;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'en_IN');

    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: indexes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = indexes[index];
          final color = item.isPositive ? AppColors.positive : AppColors.negative;

          return Container(
            width: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formatter.format(item.value),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  '${item.isPositive ? '+' : ''}${item.changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goalContent});

  final ContentItem goalContent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary,
              AppColors.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              goalContent.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              goalContent.subtitle,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      )
    );
  }

}

class _AdsCarousel extends StatelessWidget {
  const _AdsCarousel({required this.ads});

  final List<ContentItem> ads;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: ads.length,
        itemBuilder: (context, index) {
          final ad = ads[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ad.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ad.subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<FundCategory> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat.id == selected;

          return FilterChip(
            label: Text(cat.name),
            selected: isSelected,
            onSelected: (_) => onSelected(cat.id),
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
            checkmarkColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }
}

class _FundCard extends StatelessWidget {
  const _FundCard({required this.fund, required this.rank});

  final MutualFund fund;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final isPositive = fund.returns1Y >= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fund.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    fund.amc,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${fund.nav.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${isPositive ? '+' : ''}${fund.returns1Y.toStringAsFixed(1)}% (1Y)',
                  style: TextStyle(
                    fontSize: 12,
                    color: isPositive ? AppColors.positive : AppColors.negative,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlogCard extends StatelessWidget {
  const _BlogCard({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
          child: const Icon(Icons.article_outlined, color: AppColors.secondary, size: 20),
        ),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(item.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: () {},
      ),
    );
  }
}
