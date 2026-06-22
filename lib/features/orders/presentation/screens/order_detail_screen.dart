import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/orders_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Order Details',
          style: HATextStyles.h3
              .copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => const Center(child: Text('Error loading order')),
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          return _OrderDetailContent(order: order);
        },
      ),
    );
  }
}

class _OrderDetailContent extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderDetailContent({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String? ?? 'pending';
    final items = (order['items'] as List?)?.cast<Map>() ?? [];
    final address = order['address'] as Map? ?? {};
    final orderId = order['id'] as String? ?? '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status tracker
        _StatusTracker(status: status),
        const SizedBox(height: 16),

        // Order ID + COD badge
        _Section(
          title: 'Order Info',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow('Order ID', '#${orderId.substring(0, 8).toUpperCase()}'),
              const SizedBox(height: 6),
              const _InfoRow('Payment', 'Cash on Delivery'),
              const SizedBox(height: 6),
              _InfoRow('Status', orderStatusLabel(status)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Delivery address
        _Section(
          title: 'Delivery Address',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(address['fullName'] ?? '',
                  style: HATextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
              Text(address['phone'] ?? '', style: HATextStyles.bodySmall),
              const SizedBox(height: 4),
              Text(
                [
                  address['addressLine1'],
                  if ((address['addressLine2'] as String?)?.isNotEmpty ?? false)
                    address['addressLine2'],
                  '${address['city']}, ${address['state']} ${address['postalCode']}',
                ].join('\n'),
                style: HATextStyles.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Items
        _Section(
          title: '${items.length} Item${items.length != 1 ? 's' : ''}',
          child: Column(
            children: items
                .map((item) =>
                    _OrderItemRow(item: Map<String, dynamic>.from(item)))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Totals
        _Section(
          title: 'Price Details',
          child: Column(
            children: [
              _PriceRow('Subtotal',
                  '\$${((order['subtotal'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              _PriceRow(
                'Delivery',
                (order['deliveryFee'] as num?)?.toDouble() == 0
                    ? 'FREE'
                    : '\$${((order['deliveryFee'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
              ),
              if ((order['totalSavings'] as num?)?.toDouble() != null &&
                  (order['totalSavings'] as num).toDouble() > 0) ...[
                const SizedBox(height: 6),
                _PriceRow('Savings',
                    '-\$${(order['totalSavings'] as num).toDouble().toStringAsFixed(2)}',
                    color: HAColors.success),
              ],
              const Divider(height: 16),
              _PriceRow('Total',
                  '\$${((order['total'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
                  isBold: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusTracker extends StatelessWidget {
  final String status;

  const _StatusTracker({required this.status});

  static const _steps = [
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered'
  ];

  int get _currentIndex => _steps.indexOf(status).clamp(0, _steps.length - 1);

  @override
  Widget build(BuildContext context) {
    if (status == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: HAColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HAColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: HAColors.error),
            const SizedBox(width: 12),
            Text('Order Cancelled',
                style: HATextStyles.bodyMedium.copyWith(
                    color: HAColors.error, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? HAColors.darkSurface : HAColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Status',
              style:
                  HATextStyles.labelLarge.copyWith(color: HAColors.secondary)),
          const SizedBox(height: 16),
          Row(
            children: _steps.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              final isDone = i <= _currentIndex;
              final isLast = i == _steps.length - 1;

              return Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone
                                ? HAColors.secondary
                                : HAColors.secondary.withValues(alpha: 0.2),
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check_rounded,
                                    size: 16, color: Colors.white)
                                : Text('${i + 1}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 11)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          orderStatusLabel(step),
                          style: HATextStyles.labelSmall.copyWith(
                            fontSize: 9,
                            color: isDone
                                ? HAColors.secondary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 20),
                          color: i < _currentIndex
                              ? HAColors.secondary
                              : HAColors.secondary.withValues(alpha: 0.2),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final Map<String, dynamic> item;

  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl = item['productImage'] as String? ?? '';
    final name = item['productName'] as String? ?? '';
    final qty = (item['quantity'] as num?)?.toInt() ?? 1;
    final total = (item['total'] as num?)?.toDouble() ?? 0;
    final variant = item['variantName'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 50,
                height: 50,
                color: HAColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.image_outlined, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: HATextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (variant != null)
                  Text(variant,
                      style: HATextStyles.labelSmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5))),
                Text('Qty: $qty', style: HATextStyles.labelSmall),
              ],
            ),
          ),
          Text('\$${total.toStringAsFixed(2)}',
              style:
                  HATextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? HAColors.darkSurface : HAColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  HATextStyles.labelLarge.copyWith(color: HAColors.secondary)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ',
            style: HATextStyles.bodySmall.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6))),
        Text(value,
            style:
                HATextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _PriceRow(this.label, this.value, {this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: isBold
                ? HATextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)
                : HATextStyles.bodyMedium),
        Text(value,
            style: (isBold
                    ? HATextStyles.priceMain
                    : HATextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600))
                .copyWith(color: color)),
      ],
    );
  }
}
