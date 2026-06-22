import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/ha_shimmer.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../../domain/entities/product_entity.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  ProductVariant? _selectedVariant;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (product) => _buildContent(context, product, isDark),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductEntity product, bool isDark) {
    final isInCart = ref.watch(cartProvider.select((c) => c.hasProduct(product.id)));
    final cartItem = ref.watch(cartProvider.select((c) => c.getItem(product.id)));

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildImageSliver(product, isDark),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? HAColors.darkBg : HAColors.lightBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    _buildDragHandle(isDark),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategoryBadge(product, isDark),
                          const SizedBox(height: 8),
                          _buildNameAndPrice(product, isDark),
                          const SizedBox(height: 16),
                          _buildRatingRow(product, isDark),
                          const SizedBox(height: 24),
                          if (product.variants.isNotEmpty) ...[
                            _buildVariants(product, isDark),
                            const SizedBox(height: 24),
                          ],
                          _buildDescription(product, isDark),
                          const SizedBox(height: 24),
                          _buildSpecifications(product, isDark),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomBar(context, product, isInCart, cartItem, isDark),
        ),
      ],
    );
  }

  Widget _buildImageSliver(ProductEntity product, bool isDark) =>
      SliverAppBar(
        expandedHeight: 380,
        pinned: true,
        backgroundColor: isDark ? HAColors.darkBg : HAColors.lightBg,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: (isDark ? HAColors.darkCard : HAColors.lightCard).withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              size: 16,
              color: isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: (isDark ? HAColors.darkCard : HAColors.lightCard).withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.favorite_border_rounded, size: 18, color: HAColors.error),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: _buildImageGallery(product, isDark),
        ),
      );

  Widget _buildImageGallery(ProductEntity product, bool isDark) => Column(
    children: [
      Expanded(
        child: product.imageUrls.isEmpty
            ? Container(
                color: isDark ? HAColors.darkElevated : HAColors.lightElevated,
                child: const Icon(Icons.image_outlined, color: HAColors.slate400, size: 64),
              )
            : PageView.builder(
                itemCount: product.imageUrls.length,
                onPageChanged: (i) => setState(() => _selectedImageIndex = i),
                itemBuilder: (_, i) => Hero(
                  tag: 'product_image_${product.id}',
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrls[i],
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: isDark ? HAColors.darkElevated : HAColors.lightElevated),
                  ),
                ),
              ),
      ),
      if (product.imageUrls.length > 1)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: product.imageUrls.asMap().entries.map((e) => GestureDetector(
              onTap: () => setState(() => _selectedImageIndex = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _selectedImageIndex == e.key ? 20 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _selectedImageIndex == e.key ? HAColors.secondary : HAColors.slate400,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            )).toList(),
          ),
        ),
    ],
  );

  Widget _buildDragHandle(bool isDark) => Center(
    child: Container(
      width: 40, height: 4,
      decoration: BoxDecoration(
        color: isDark ? HAColors.darkBorder : HAColors.lightBorder,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  Widget _buildCategoryBadge(ProductEntity product, bool isDark) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: HAColors.secondary.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      product.categoryName,
      style: HATextStyles.labelSmall.copyWith(color: HAColors.secondary),
    ),
  );

  Widget _buildNameAndPrice(ProductEntity product, bool isDark) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          product.name,
          style: HATextStyles.h3.copyWith(
            color: isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight,
          ),
        ),
      ),
      const SizedBox(width: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${product.displayPrice.toStringAsFixed(2)}',
            style: HATextStyles.priceLarge,
          ),
          if (product.isOnSale)
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: HATextStyles.priceStrikethrough,
            ),
        ],
      ),
    ],
  );

  Widget _buildRatingRow(ProductEntity product, bool isDark) => Row(
    children: [
      RatingBarIndicator(
        rating: product.rating,
        itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
        itemCount: 5,
        itemSize: 18,
        unratedColor: HAColors.slate600,
      ),
      const SizedBox(width: 8),
      Text(
        product.rating.toStringAsFixed(1),
        style: HATextStyles.labelMedium.copyWith(
          color: isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight,
        ),
      ),
      Text(
        ' · ${product.reviewCount} reviews',
        style: HATextStyles.bodySmall.copyWith(color: HAColors.slate400),
      ),
      const Spacer(),
      if (product.isInStock)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: HAColors.success.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('In Stock', style: HATextStyles.labelSmall.copyWith(color: HAColors.success)),
        )
      else
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: HAColors.error.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('Out of Stock', style: HATextStyles.labelSmall.copyWith(color: HAColors.error)),
        ),
    ],
  );

  Widget _buildVariants(ProductEntity product, bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Options',
        style: HATextStyles.h5.copyWith(
          color: isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight,
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: product.variants.map((v) {
          final isSelected = _selectedVariant?.id == v.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedVariant = isSelected ? null : v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? HAColors.secondary : (isDark ? HAColors.darkElevated : HAColors.lightElevated),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? HAColors.secondary : (isDark ? HAColors.darkBorder : HAColors.lightBorder),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Text(
                v.name,
                style: HATextStyles.labelMedium.copyWith(
                  color: isSelected ? Colors.white : (isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );

  Widget _buildDescription(ProductEntity product, bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Description',
        style: HATextStyles.h5.copyWith(
          color: isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        product.description,
        style: HATextStyles.bodyMedium.copyWith(
          color: isDark ? HAColors.textSecondaryDark : HAColors.textSecondaryLight,
          height: 1.7,
        ),
      ),
    ],
  );

  Widget _buildSpecifications(ProductEntity product, bool isDark) {
    final specs = product.specifications;
    if (specs == null || specs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: HATextStyles.h5.copyWith(
            color: isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? HAColors.darkCard : HAColors.lightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
          ),
          child: Column(
            children: specs.entries.toList().asMap().entries.map((entry) {
              final i = entry.key;
              final kv = entry.value;
              final isLast = i == specs.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            kv.key,
                            style: HATextStyles.bodySmall.copyWith(color: HAColors.slate400),
                          ),
                        ),
                        Text(
                          kv.value.toString(),
                          style: HATextStyles.labelMedium.copyWith(
                            color: isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) Divider(
                    color: isDark ? HAColors.darkDivider : HAColors.lightDivider,
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    ProductEntity product,
    bool isInCart,
    dynamic cartItem,
    bool isDark,
  ) => Container(
    padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
    decoration: BoxDecoration(
      color: isDark ? HAColors.darkSurface : HAColors.lightSurface,
      border: Border(
        top: BorderSide(
          color: isDark ? HAColors.darkBorder : HAColors.lightBorder,
        ),
      ),
    ),
    child: Row(
      children: [
        // Quantity selector
        Container(
          decoration: BoxDecoration(
            color: isDark ? HAColors.darkElevated : HAColors.lightElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded, size: 18),
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
              ),
              Text(
                '$_quantity',
                style: HATextStyles.labelLarge.copyWith(
                  color: isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded, size: 18),
                onPressed: _quantity < product.stockQuantity
                    ? () => setState(() => _quantity++)
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: product.isInStock ? HAColors.primaryGradient : null,
                color: product.isInStock ? null : HAColors.slate600,
                borderRadius: BorderRadius.circular(14),
                boxShadow: product.isInStock ? [
                  BoxShadow(
                    color: HAColors.secondary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ] : null,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: product.isInStock
                    ? () {
                        ref.read(cartProvider.notifier).addItem(
                          product,
                          quantity: _quantity,
                          variant: _selectedVariant,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart'),
                            backgroundColor: HAColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            action: SnackBarAction(
                              label: 'View Cart',
                              textColor: Colors.white,
                              onPressed: () => context.go('/cart'),
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text(
                  isInCart ? 'Add More' : 'Add to Cart',
                  style: HATextStyles.labelLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
