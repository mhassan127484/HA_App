import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/products/domain/entities/product_entity.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';

class HAProductCard extends ConsumerWidget {
  final ProductEntity product;
  final VoidCallback? onTap;
  final double? width;
  final bool compact;

  const HAProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.width,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInCart = ref.watch(cartProvider.select((c) => c.hasProduct(product.id)));
    final cardColor = isDark ? HAColors.darkCard : HAColors.lightCard;
    final borderColor = isDark ? HAColors.darkBorder : HAColors.lightBorder;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(isDark),
            Expanded(child: _buildInfoSection(context, isDark, isInCart, ref)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(bool isDark) => Stack(
    children: [
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: AspectRatio(
          aspectRatio: 1,
          child: Hero(
            tag: 'product_image_${product.id}',
            child: CachedNetworkImage(
              imageUrl: product.primaryImage,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: isDark ? HAColors.darkElevated : HAColors.lightElevated,
                child: const Center(
                  child: Icon(Icons.image_outlined, color: HAColors.slate400, size: 32),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: isDark ? HAColors.darkElevated : HAColors.lightElevated,
                child: const Icon(Icons.broken_image_outlined, color: HAColors.slate400),
              ),
            ),
          ),
        ),
      ),
      if (product.isOnSale)
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: HAColors.error,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '-${product.discountPercent}%',
              style: HATextStyles.labelSmall.copyWith(color: Colors.white),
            ),
          ),
        ),
      if (product.isFlashSale)
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: HAColors.flashSaleGradient,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, color: Colors.white, size: 12),
                const SizedBox(width: 2),
                Text('Flash', style: HATextStyles.labelSmall.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
      if (!product.isInStock)
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Out of Stock',
                    style: HATextStyles.labelSmall.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );

  Widget _buildInfoSection(BuildContext context, bool isDark, bool isInCart, WidgetRef ref) =>
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: HATextStyles.labelMedium.copyWith(
                color: isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight,
              ),
              maxLines: compact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!compact) ...[
              const SizedBox(height: 4),
              _buildRating(isDark),
            ],
            const Spacer(),
            _buildPriceRow(isDark, isInCart, ref),
          ],
        ),
      );

  Widget _buildRating(bool isDark) => Row(
    children: [
      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
      const SizedBox(width: 2),
      Text(
        product.rating.toStringAsFixed(1),
        style: HATextStyles.labelSmall.copyWith(
          color: isDark ? HAColors.textSecondaryDark : HAColors.textSecondaryLight,
        ),
      ),
      Text(
        ' (${product.reviewCount})',
        style: HATextStyles.labelSmall.copyWith(color: HAColors.slate400),
      ),
    ],
  );

  Widget _buildPriceRow(bool isDark, bool isInCart, WidgetRef ref) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\$${product.displayPrice.toStringAsFixed(2)}',
            style: HATextStyles.priceSmall,
          ),
          if (product.isOnSale)
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: HATextStyles.priceStrikethrough,
            ),
        ],
      ),
      GestureDetector(
        onTap: () {
          if (!isInCart) {
            ref.read(cartProvider.notifier).addItem(product);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isInCart ? HAColors.success : HAColors.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isInCart ? Icons.check_rounded : Icons.add_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    ],
  );
}
