import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ha_ecommerce/core/theme/app_theme.dart';

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    final haColors = context.haColors;
    return Shimmer.fromColors(
      baseColor: haColors.shimmerBase,
      highlightColor: haColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: haColors.shimmerBase,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SkeletonProductCard extends StatelessWidget {
  const SkeletonProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.haColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.cs.outline.withOpacity(0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 160, borderRadius: AppRadius.lg),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                SkeletonBox(width: 120, height: 12),
                const SizedBox(height: 10),
                SkeletonBox(width: 80, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonBanner extends StatelessWidget {
  const SkeletonBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(height: 180, borderRadius: AppRadius.xl);
  }
}

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SkeletonBox(width: 56, height: 56, borderRadius: AppRadius.lg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                SkeletonBox(width: 160, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonGrid extends StatelessWidget {
  final int count;
  const SkeletonGrid({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: count,
      itemBuilder: (_, __) => const SkeletonProductCard(),
    );
  }
}
