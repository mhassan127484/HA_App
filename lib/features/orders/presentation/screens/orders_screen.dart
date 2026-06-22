import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/orders_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(userOrdersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'My Orders',
          style: HATextStyles.h3.copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (orders) {
          if (orders.isEmpty) return const _EmptyOrdersView();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _OrderCard(order: orders[index]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = order['status'] as String? ?? 'pending';
    final items = (order['items'] as List?)?.cast<Map>() ?? [];
    final total = (order['total'] as num?)?.toDouble() ?? 0.0;
    final orderId = order['id'] as String? ?? '';
    final createdAt = (order['createdAt'] as dynamic);

    return GestureDetector(
      onTap: () => context.push('/orders/${order['id']}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? HAColors.darkSurface : HAColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${orderId.substring(0, 8).toUpperCase()}',
                  style: HATextStyles.labelMedium.copyWith(
                    fontFamily: 'monospace',
                    color: HAColors.secondary,
                  ),
                ),
                _StatusChip(status: status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${items.length} item${items.length != 1 ? 's' : ''} · \$${total.toStringAsFixed(2)}',
              style: HATextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                items.take(2).map((i) => i['productName'] ?? '').join(', ') +
                    (items.length > 2 ? ' +${items.length - 2} more' : ''),
                style: HATextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.payments_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text('Cash on Delivery', style: HATextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                )),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: HAColors.secondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color get _color => switch (status) {
        'delivered' => HAColors.success,
        'cancelled' => HAColors.error,
        'shipped' => HAColors.accent,
        'processing' || 'confirmed' => HAColors.warning,
        _ => HAColors.secondary.withOpacity(0.7),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        orderStatusLabel(status),
        style: HATextStyles.labelSmall.copyWith(color: _color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyOrdersView extends StatelessWidget {
  const _EmptyOrdersView();

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
              child: Icon(Icons.receipt_long_outlined, size: 56, color: HAColors.secondary),
            ),
            const SizedBox(height: 24),
            Text('No Orders Yet', style: HATextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Your order history will appear here once you make a purchase.',
              textAlign: TextAlign.center,
              style: HATextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
