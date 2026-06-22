import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

final adminProductsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('products')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(adminProductsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Products', style: HATextStyles.h3.copyWith(color: Theme.of(context).colorScheme.onSurface)),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: HAColors.secondary),
            onPressed: () => context.push('/admin/products/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? HAColors.darkSurface
                    : HAColors.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),

          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (products) {
                final filtered = _search.isEmpty
                    ? products
                    : products.where((p) => (p['name'] as String? ?? '').toLowerCase().contains(_search)).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _AdminProductRow(product: filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminProductRow extends ConsumerWidget {
  final Map<String, dynamic> product;

  const _AdminProductRow({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final images = (product['images'] as List?)?.cast<String>() ?? [];
    final name = product['name'] as String? ?? '';
    final price = (product['price'] as num?)?.toDouble() ?? 0;
    final stock = (product['stockQuantity'] as num?)?.toInt() ?? 0;
    final isActive = product['isActive'] as bool? ?? true;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? HAColors.darkSurface : HAColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: images.isNotEmpty ? images.first : '',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: HAColors.primary.withOpacity(0.1),
                child: const Icon(Icons.image_outlined, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: HATextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text('\$${price.toStringAsFixed(2)}', style: HATextStyles.labelMedium.copyWith(color: HAColors.secondary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: stock > 0 ? HAColors.success.withOpacity(0.1) : HAColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        stock > 0 ? 'Stock: $stock' : 'Out of Stock',
                        style: HATextStyles.labelSmall.copyWith(
                          color: stock > 0 ? HAColors.success : HAColors.error,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toggle active
              Switch.adaptive(
                value: isActive,
                onChanged: (val) {
                  FirebaseFirestore.instance
                      .collection('products')
                      .doc(product['id'])
                      .update({'isActive': val});
                },
                activeColor: HAColors.secondary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              // Delete
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, size: 20, color: HAColors.error),
                onPressed: () => _confirmDelete(context, product['id'], name),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('products').doc(id).delete();
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: HAColors.error)),
          ),
        ],
      ),
    );
  }
}
