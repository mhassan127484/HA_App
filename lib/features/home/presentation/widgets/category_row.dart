import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../products/presentation/providers/product_provider.dart';

class CategoryRow extends ConsumerWidget {
  const CategoryRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Categories',
            style: HATextStyles.h4.copyWith(
              color: isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 90,
          child: categories.when(
            loading: () => _buildSkeletons(),
            error: (_, __) => const SizedBox.shrink(),
            data: (cats) => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) => _CategoryChip(category: cats[i], isDark: isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletons() => ListView.separated(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    itemCount: 6,
    separatorBuilder: (_, __) => const SizedBox(width: 12),
    itemBuilder: (_, __) => Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: HAColors.darkElevated,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 6),
        Container(width: 50, height: 10, color: HAColors.darkElevated),
      ],
    ),
  );
}

class _CategoryChip extends StatelessWidget {
  final dynamic category;
  final bool isDark;
  const _CategoryChip({required this.category, required this.isDark});

  static const _icons = {
    'electronics': Icons.devices_rounded,
    'clothing': Icons.checkroom_rounded,
    'shoes': Icons.roller_skating_rounded,
    'accessories': Icons.watch_rounded,
    'home': Icons.home_rounded,
    'beauty': Icons.spa_rounded,
    'sports': Icons.sports_basketball_rounded,
    'books': Icons.menu_book_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _icons[category.name.toLowerCase()] ?? Icons.category_rounded;
    final colorHex = category.colorHex ?? '#3B82F6';
    final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

    return GestureDetector(
      onTap: () => context.go('/products?category=${category.id}'),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            style: HATextStyles.labelSmall.copyWith(
              color: isDark ? HAColors.textSecondaryDark : HAColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
