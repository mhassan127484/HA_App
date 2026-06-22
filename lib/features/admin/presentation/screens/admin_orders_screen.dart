import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

final adminOrdersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('orders')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String _filterStatus = 'all';

  static const _statuses = [
    'all',
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Manage Orders',
            style: HATextStyles.h3
                .copyWith(color: Theme.of(context).colorScheme.onSurface)),
      ),
      body: Column(
        children: [
          // Status filter chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final s = _statuses[i];
                final isSelected = _filterStatus == s;
                return GestureDetector(
                  onTap: () => setState(() => _filterStatus = s),
                  child: Chip(
                    label: Text(
                      s == 'all' ? 'All' : _capitalize(s),
                      style: HATextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    backgroundColor: isSelected ? HAColors.secondary : null,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (orders) {
                final filtered = _filterStatus == 'all'
                    ? orders
                    : orders
                        .where((o) => o['status'] == _filterStatus)
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                      child: Text(
                          'No ${_filterStatus == 'all' ? '' : _filterStatus} orders'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) =>
                      _AdminOrderCard(order: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _AdminOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _AdminOrderCard({required this.order});

  Color _statusColor(String status) => switch (status) {
        'delivered' => HAColors.success,
        'cancelled' => HAColors.error,
        'shipped' => HAColors.accent,
        'processing' || 'confirmed' => HAColors.warning,
        _ => HAColors.secondary.withValues(alpha: 0.7),
      };

  static const _nextStatus = <String, String>{
    'pending': 'confirmed',
    'confirmed': 'processing',
    'processing': 'shipped',
    'shipped': 'delivered',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = order['status'] as String? ?? 'pending';
    final orderId =
        (order['id'] as String? ?? '').substring(0, 8).toUpperCase();
    final total = (order['total'] as num?)?.toDouble() ?? 0;
    final items = (order['items'] as List?)?.cast<Map>() ?? [];
    final address = order['address'] as Map? ?? {};

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? HAColors.darkSurface : HAColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#$orderId',
                  style: HATextStyles.labelMedium.copyWith(
                      fontFamily: 'monospace', color: HAColors.secondary)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status,
                    style: HATextStyles.labelSmall.copyWith(
                        color: _statusColor(status),
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${items.length} items · \$${total.toStringAsFixed(2)}',
            style:
                HATextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          if ((address['fullName'] as String?)?.isNotEmpty ?? false) ...[
            const SizedBox(height: 2),
            Text(
              '${address['fullName']} · ${address['city'] ?? ''}',
              style: HATextStyles.bodySmall.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6)),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              if (_nextStatus.containsKey(status)) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: Text('Mark as ${_capitalize(_nextStatus[status]!)}'),
                    onPressed: () =>
                        _updateStatus(order['id'], _nextStatus[status]!),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: HAColors.secondary,
                      side: const BorderSide(color: HAColors.secondary),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: HATextStyles.labelSmall,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (status == 'pending') ...[
                OutlinedButton(
                  onPressed: () => _updateStatus(order['id'], 'cancelled'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HAColors.error,
                    side: const BorderSide(color: HAColors.error),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    textStyle: HATextStyles.labelSmall,
                  ),
                  child: const Text('Cancel'),
                ),
              ],
              if (!_nextStatus.containsKey(status) && status != 'pending')
                Expanded(
                  child: Text(
                    status == 'delivered'
                        ? '✓ Order completed'
                        : 'Order cancelled',
                    textAlign: TextAlign.center,
                    style: HATextStyles.labelSmall
                        .copyWith(color: _statusColor(status)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void _updateStatus(String orderId, String newStatus) {
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([
        {
          'status': newStatus,
          'timestamp': Timestamp.now(),
          'note': 'Status updated by admin',
        }
      ]),
    });
  }
}
