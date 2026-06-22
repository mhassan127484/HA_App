import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ha_ecommerce/core/theme/app_theme.dart';
import 'package:ha_ecommerce/features/cart/presentation/providers/cart_provider.dart';
import 'package:ha_ecommerce/features/products/domain/entities/product_entity.dart';

class ProductCard extends ConsumerWidget {
  final ProductEntity product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inCart = ref.watch(
      cartProvider.select((cart) => cart?.items.any((i) => i.productId == product.id) ?? false),
    );

    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: context.haColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: context.cs.outline.withOpacity(0.5),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with hero tag
            Hero(
              tag: 'product-${product.id}',
              child: _ProductImage(product: product),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand
                  if (product.brand != null)
                    Text(
                      product.brand!,
                      style: context.tt.bodySmall?.copyWith(
                        color: context.cs.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 2),
                  // Name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.tt.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  // Rating
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: product.rating,
                        itemSize: 12,
                        itemBuilder: (_, __) => Icon(
                          Icons.star,
                          color: context.haColors.starColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviewCount})',
                        style: context.tt.bodySmall?.copyWith(
                          color: context.cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Price row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${product.effectivePrice.toStringAsFixed(2)}',
                              style: context.tt.titleLarge?.copyWith(
                                color: context.cs.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (product.hasDiscount)
                              Text(
                                '\$${product.compareAtPrice!.toStringAsFixed(2)}',
                                style: context.tt.bodySmall?.copyWith(
                                  color: context.cs.onSurfaceVariant,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Add to cart button
                      GestureDetector(
                        onTap: () {
                          ref.read(cartProvider.notifier).addToCart(product);
                        },
                        child: AnimatedContainer(
                          duration: 300.ms,
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: inCart ? context.cs.primary : context.cs.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            inCart ? Icons.shopping_bag : Icons.add,
                            size: 16,
                            color: inCart ? Colors.white : context.cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final ProductEntity product;
  const _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: product.primaryImage.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.primaryImage,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: context.cs.surfaceContainerHighest,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: context.cs.surfaceContainerHighest,
                      child: const Icon(Icons.image_outlined, size: 40),
                    ),
                  )
                : Container(
                    color: context.cs.surfaceContainerHighest,
                    child: const Icon(Icons.image_outlined, size: 40),
                  ),
          ),
        ),
        // Badges
        Positioned(
          top: 8,
          left: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.isOnFlashSale)
                _Badge(label: 'Sale', color: AppColors.error),
              if (product.isFeatured)
                _Badge(label: 'Featured', color: AppColors.secondary),
              if (!product.isInStock)
                _Badge(label: 'Sold out', color: AppColors.slate500),
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
