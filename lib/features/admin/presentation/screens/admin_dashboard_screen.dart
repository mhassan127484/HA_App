import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Providers for dashboard stats
final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  final futures = await Future.wait([
    firestore.collection('orders').get(),
    firestore.collection('products').get(),
    firestore.collection('users').get(),
    firestore.collection('orders').where('status', isEqualTo: 'pending').get(),
  ]);

  final orders = futures[0];
  final products = futures[1];
  final users = futures[2];
  final pending = futures[3];

  double totalRevenue = 0;
  for (final doc in orders.docs) {
    totalRevenue += ((doc.data()['total'] as num?)?.toDouble() ?? 0);
  }

  return {
    'totalOrders': orders.size,
    'totalProducts': products.size,
    'totalUsers': users.size,
    'pendingOrders': pending.size,
    'totalRevenue': totalRevenue,
  };
});

final recentOrdersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('orders')
      .orderBy('createdAt', descending: true)
      .limit(5)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final recentAsync = ref.watch(recentOrdersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: HAColors.primary,
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Admin Dashboard',
                  style: HATextStyles.h3.copyWith(color: Colors.white)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      HAColors.primary,
                      HAColors.secondary.withValues(alpha: 0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).signOut(),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats grid
                statsAsync.when(
                  loading: () => const _StatsGridSkeleton(),
                  error: (e, _) => Text('Error: $e'),
                  data: (stats) => _StatsGrid(stats: stats),
                ),
                const SizedBox(height: 20),

                // Quick actions
                Text('Quick Actions',
                    style: HATextStyles.h4.copyWith(
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 12),
                _QuickActions(),
                const SizedBox(height: 20),

                // Recent orders
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Orders',
                        style: HATextStyles.h4.copyWith(
                            color: Theme.of(context).colorScheme.onSurface)),
                    TextButton(
                      onPressed: () => context.push('/admin/orders'),
                      child: const Text('View All',
                          style: TextStyle(color: HAColors.secondary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                recentAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (orders) => orders.isEmpty
                      ? const Center(child: Text('No orders yet'))
                      : Column(
                          children: orders
                              .map((o) => _RecentOrderRow(order: o))
                              .toList(),
                        ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _StatCard(
          label: 'Total Revenue',
          value: '\$${(stats['totalRevenue'] as double).toStringAsFixed(0)}',
          icon: Icons.attach_money_rounded,
          color: HAColors.success,
        ),
        _StatCard(
          label: 'Total Orders',
          value: '${stats['totalOrders']}',
          icon: Icons.receipt_long_outlined,
          color: HAColors.secondary,
        ),
        _StatCard(
          label: 'Pending Orders',
          value: '${stats['pendingOrders']}',
          icon: Icons.pending_actions_outlined,
          color: HAColors.warning,
        ),
        _StatCard(
          label: 'Products',
          value: '${stats['totalProducts']}',
          icon: Icons.inventory_2_outlined,
          color: HAColors.accent,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: HATextStyles.h3.copyWith(color: color)),
              Text(label,
                  style: HATextStyles.labelSmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGridSkeleton extends StatelessWidget {
  const _StatsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: List.generate(
          4,
          (_) => Container(
                decoration: BoxDecoration(
                  color: isDark ? HAColors.darkSurface : HAColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
              )),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _ActionButton(
          icon: Icons.add_box_outlined,
          label: 'Add Product',
          color: HAColors.secondary,
          onTap: () => context.push('/admin/products/add'),
        )),
        const SizedBox(width: 12),
        Expanded(
            child: _ActionButton(
          icon: Icons.inventory_2_outlined,
          label: 'Products',
          color: HAColors.accent,
          onTap: () => context.push('/admin/products'),
        )),
        const SizedBox(width: 12),
        Expanded(
            child: _ActionButton(
          icon: Icons.list_alt_outlined,
          label: 'Orders',
          color: HAColors.warning,
          onTap: () => context.push('/admin/orders'),
        )),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(label,
                style: HATextStyles.labelSmall.copyWith(color: color),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _RecentOrderRow extends StatelessWidget {
  final Map<String, dynamic> order;

  const _RecentOrderRow({required this.order});

  Color _statusColor(String status) => switch (status) {
        'delivered' => HAColors.success,
        'cancelled' => HAColors.error,
        'shipped' => HAColors.accent,
        _ => HAColors.warning,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = order['status'] as String? ?? 'pending';
    final orderId =
        (order['id'] as String? ?? '').substring(0, 8).toUpperCase();
    final total = (order['total'] as num?)?.toDouble() ?? 0;

    return GestureDetector(
      onTap: () => context.push('/orders/${order['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? HAColors.darkSurface : HAColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text('#$orderId',
                  style: HATextStyles.labelMedium
                      .copyWith(fontFamily: 'monospace')),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor(status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(status,
                  style: HATextStyles.labelSmall
                      .copyWith(color: _statusColor(status))),
            ),
            const SizedBox(width: 12),
            Text('\$${total.toStringAsFixed(2)}',
                style: HATextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
