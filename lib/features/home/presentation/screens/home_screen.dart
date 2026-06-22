import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ha_product_card.dart';
import '../../../../core/widgets/ha_shimmer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_row.dart';
import '../widgets/flash_sale_section.dart';
import '../widgets/section_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isDark, user?.displayName),
          SliverToBoxAdapter(child: _buildSearchBar(context, isDark)),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          const SliverToBoxAdapter(child: BannerCarousel()),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          const SliverToBoxAdapter(child: CategoryRow()),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          const SliverToBoxAdapter(child: FlashSaleSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          _buildFeaturedSection(context, ref, isDark),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          _buildTrendingSection(context, ref, isDark),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, String? name) =>
      SliverAppBar(
        floating: true,
        pinned: false,
        snap: true,
        backgroundColor: isDark ? HAColors.darkBg : HAColors.lightBg,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_greeting()},',
                  style: HATextStyles.bodySmall.copyWith(
                    color: isDark ? HAColors.textSecondaryDark : HAColors.textSecondaryLight,
                  ),
                ),
                Text(
                  name?.split(' ').first ?? 'Shopper',
                  style: HATextStyles.h4.copyWith(
                    color: isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: HAColors.secondary.withOpacity(0.15),
              child: const Icon(Icons.person_rounded, color: HAColors.secondary, size: 20),
            ),
          ),
        ],
      );

  Widget _buildSearchBar(BuildContext context, bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: GestureDetector(
      onTap: () => context.push('/products'),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? HAColors.darkElevated : HAColors.lightElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? HAColors.darkBorder : HAColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: HAColors.slate400, size: 20),
            const SizedBox(width: 12),
            Text(
              'Search products, brands...',
              style: HATextStyles.bodyMedium.copyWith(color: HAColors.slate400),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildFeaturedSection(BuildContext context, WidgetRef ref, bool isDark) {
    final featured = ref.watch(featuredProductsProvider);
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(
              title: 'Featured',
              onSeeAll: () => context.go('/products'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: featured.when(
              loading: () => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, __) => const SizedBox(
                  width: 180,
                  child: HAProductCardSkeleton(),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (products) => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (ctx, i) => SizedBox(
                  width: 180,
                  child: HAProductCard(
                    product: products[i],
                    onTap: () => context.push('/products/${products[i].id}'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection(BuildContext context, WidgetRef ref, bool isDark) {
    final trending = ref.watch(trendingProductsProvider);
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(
              title: 'Trending Now',
              onSeeAll: () => context.go('/products'),
            ),
          ),
          const SizedBox(height: 16),
          trending.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                HAProductCardSkeleton(),
                SizedBox(height: 14),
                HAProductCardSkeleton(),
              ]),
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (products) => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: products.take(5).length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (ctx, i) => _TrendingProductTile(
                product: products[i],
                rank: i + 1,
                onTap: () => context.push('/products/${products[i].id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _TrendingProductTile extends StatelessWidget {
  final dynamic product;
  final int rank;
  final VoidCallback onTap;

  const _TrendingProductTile({
    required this.product,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? HAColors.darkCard : HAColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? HAColors.darkBorder : HAColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Text(
              '#$rank',
              style: HATextStyles.h4.copyWith(
                color: rank <= 3 ? HAColors.secondary : HAColors.slate400,
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 64,
                height: 64,
                color: isDark ? HAColors.darkElevated : HAColors.lightElevated,
                child: const Icon(Icons.image_outlined, color: HAColors.slate400),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: HATextStyles.labelLarge.copyWith(
                      color: isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.categoryName,
                    style: HATextStyles.bodySmall.copyWith(color: HAColors.slate400),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${product.displayPrice.toStringAsFixed(2)}',
                  style: HATextStyles.priceSmall,
                ),
                if (product.isOnSale)
                  Text(
                    '-${product.discountPercent}%',
                    style: HATextStyles.labelSmall.copyWith(color: HAColors.error),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
