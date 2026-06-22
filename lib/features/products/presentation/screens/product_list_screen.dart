import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ha_product_card.dart';
import '../../../../core/widgets/ha_shimmer.dart';
import '../providers/product_provider.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  final String? initialCategoryId;
  const ProductListScreen({super.key, this.initialCategoryId});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _scrollController = ScrollController();
  String _viewMode = 'grid'; // 'grid' | 'list'

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(productListProvider.notifier).loadProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListProvider);
    final categories = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              _viewMode == 'grid' ? Icons.view_list_rounded : Icons.grid_view_rounded,
            ),
            onPressed: () => setState(() => _viewMode = _viewMode == 'grid' ? 'list' : 'grid'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(categories, isDark),
          _buildSortBar(state, isDark),
          Expanded(
            child: state.products.isEmpty && state.isLoading
                ? _buildSkeletonGrid()
                : _buildProductGrid(state, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(AsyncValue categories, bool isDark) => SizedBox(
    height: 48,
    child: categories.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (cats) => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: cats.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final isAll = i == 0;
          final category = isAll ? null : cats[i - 1];
          final state = ref.watch(productListProvider);
          final isSelected = isAll
              ? state.categoryFilter == null
              : state.categoryFilter == category!.id;

          return GestureDetector(
            onTap: () => ref.read(productListProvider.notifier).setCategory(
              isAll ? null : category!.id,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? HAColors.secondary
                    : (isDark ? HAColors.darkElevated : HAColors.lightElevated),
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
              ),
              child: Center(
                child: Text(
                  isAll ? 'All' : category!.name,
                  style: HATextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _buildSortBar(dynamic state, bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Row(
      children: [
        Text(
          '${state.products.length} products',
          style: HATextStyles.bodySmall.copyWith(color: HAColors.slate400),
        ),
        const Spacer(),
        DropdownButton<String>(
          value: state.sortBy,
          underline: const SizedBox.shrink(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          style: HATextStyles.labelMedium.copyWith(
            color: isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight,
          ),
          items: const [
            DropdownMenuItem(value: 'newest', child: Text('Newest')),
            DropdownMenuItem(value: 'price_asc', child: Text('Price: Low-High')),
            DropdownMenuItem(value: 'price_desc', child: Text('Price: High-Low')),
            DropdownMenuItem(value: 'rating', child: Text('Top Rated')),
          ],
          onChanged: (v) => ref.read(productListProvider.notifier).setSortBy(v!),
        ),
      ],
    ),
  );

  Widget _buildProductGrid(dynamic state, bool isDark) {
    if (_viewMode == 'grid') {
      return GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: state.products.length + (state.isLoading ? 2 : 0),
        itemBuilder: (ctx, i) {
          if (i >= state.products.length) return const HAProductCardSkeleton();
          final product = state.products[i];
          return HAProductCard(
            product: product,
            onTap: () => context.push('/products/${product.id}'),
          );
        },
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: state.products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final product = state.products[i];
        return _ProductListTile(
          product: product,
          onTap: () => context.push('/products/${product.id}'),
          isDark: isDark,
        );
      },
    );
  }

  Widget _buildSkeletonGrid() => GridView.builder(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.68,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
    ),
    itemCount: 6,
    itemBuilder: (_, __) => const HAProductCardSkeleton(),
  );
}

class _ProductListTile extends StatelessWidget {
  final dynamic product;
  final VoidCallback onTap;
  final bool isDark;

  const _ProductListTile({required this.product, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? HAColors.darkCard : HAColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                    Text(
                      ' ${product.rating.toStringAsFixed(1)} (${product.reviewCount})',
                      style: HATextStyles.bodySmall.copyWith(color: HAColors.slate400),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.displayPrice.toStringAsFixed(2)}',
                  style: HATextStyles.priceSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
