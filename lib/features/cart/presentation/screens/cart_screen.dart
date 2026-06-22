import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons/ha_button.dart';
import '../../domain/entities/cart_entity.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'My Cart',
          style: HATextStyles.h3.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => _showClearDialog(context, ref),
              child: Text(
                'Clear All',
                style: HATextStyles.labelMedium.copyWith(
                  color: HAColors.error,
                ),
              ),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _EmptyCartView(onShopNow: () => context.go('/home'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _CartItemCard(item: item);
                    },
                  ),
                ),
                _OrderSummary(cart: cart),
              ],
            ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(ctx);
            },
            child: Text('Clear', style: TextStyle(color: HAColors.error)),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  final CartItemEntity item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: HAColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline_rounded, color: HAColors.error, size: 28),
      ),
      onDismissed: (_) {
        ref.read(cartProvider.notifier).removeItem(item.product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.product.name} removed from cart'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => ref.read(cartProvider.notifier).addItem(item.product, quantity: item.quantity),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? HAColors.darkSurface : HAColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? HAColors.darkBorder : HAColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: item.product.images.isNotEmpty ? item.product.images.first : '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: HAColors.primary.withOpacity(0.1),
                  child: Icon(Icons.image_outlined, color: HAColors.primary.withOpacity(0.5)),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: HATextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.selectedVariant != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.selectedVariant!.name,
                      style: HATextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${item.itemTotal.toStringAsFixed(2)}',
                            style: HATextStyles.priceMain.copyWith(fontSize: 16),
                          ),
                          if (item.product.isOnSale)
                            Text(
                              '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                              style: HATextStyles.priceOriginal.copyWith(fontSize: 12),
                            ),
                        ],
                      ),

                      // Quantity Controls
                      _QuantityControl(item: item),
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

class _QuantityControl extends ConsumerWidget {
  final CartItemEntity item;

  const _QuantityControl({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? HAColors.darkBackground : HAColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: item.quantity == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
            color: item.quantity == 1 ? HAColors.error : null,
            onTap: () {
              if (item.quantity == 1) {
                ref.read(cartProvider.notifier).removeItem(item.product.id);
              } else {
                ref.read(cartProvider.notifier).updateQuantity(item.product.id, item.quantity - 1);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${item.quantity}',
              style: HATextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          _QtyButton(
            leadingIcon: Icons.add_rounded,
            onTap: () => ref.read(cartProvider.notifier).updateQuantity(item.product.id, item.quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _QtyButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: color ?? Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

class _OrderSummary extends ConsumerWidget {
  final CartEntity cart;

  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? HAColors.darkSurface : HAColors.lightSurface,
        border: Border(
          top: BorderSide(color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow('Subtotal (${cart.itemCount} items)', '\$${cart.subtotal.toStringAsFixed(2)}'),
          if (cart.totalSavings > 0) ...[
            const SizedBox(height: 6),
            _SummaryRow('Savings', '-\$${cart.totalSavings.toStringAsFixed(2)}', valueColor: HAColors.success),
          ],
          const SizedBox(height: 6),
          _SummaryRow(
            'Delivery',
            cart.freeDelivery ? 'FREE' : '\$${cart.deliveryFee.toStringAsFixed(2)}',
            valueColor: cart.freeDelivery ? HAColors.success : null,
          ),
          if (!cart.freeDelivery) ...[
            const SizedBox(height: 4),
            Text(
              'Add \$${(50 - cart.subtotal).toStringAsFixed(2)} more for free delivery',
              style: HATextStyles.bodySmall.copyWith(color: HAColors.secondary),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _SummaryRow(
            'Total',
            '\$${cart.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: 16),
          HAButton(
            label: 'Proceed to Checkout',
            onPressed: () => context.push('/checkout'),
            
            leadingIcon: Icons.arrow_forward_rounded,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  const _SummaryRow(this.label, this.value, {this.isTotal = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? HATextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)
              : HATextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
        ),
        Text(
          value,
          style: isTotal
              ? HATextStyles.priceMain
              : HATextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                ),
        ),
      ],
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  final VoidCallback onShopNow;

  const _EmptyCartView({required this.onShopNow});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HAColors.secondary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 56,
                color: HAColors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: HATextStyles.h3.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\'t added anything yet. Start shopping!',
              textAlign: TextAlign.center,
              style: HATextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            HAButton(
              label: 'Start Shopping',
              onPressed: onShopNow,
              leadingIcon: Icons.storefront_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
