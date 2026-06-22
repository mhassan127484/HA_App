import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class HAShimmer extends StatelessWidget {
  final Widget child;
  const HAShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? HAColors.shimmerBase : HAColors.shimmerBaseLight,
      highlightColor: isDark ? HAColors.shimmerHighlight : HAColors.shimmerHighlightLight,
      child: child,
    );
  }
}

class HAShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const HAShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) => HAShimmer(
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
  );
}

class HAProductCardSkeleton extends StatelessWidget {
  const HAProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? HAColors.darkCard : HAColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? HAColors.darkBorder : HAColors.lightBorder,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HAShimmerBox(height: 160, borderRadius: 0),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HAShimmerBox(width: double.infinity, height: 14),
                SizedBox(height: 8),
                HAShimmerBox(width: 100, height: 12),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HAShimmerBox(width: 60, height: 18),
                    HAShimmerBox(width: 34, height: 34, borderRadius: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HABannerSkeleton extends StatelessWidget {
  const HABannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const HAShimmerBox(
    width: double.infinity,
    height: 180,
    borderRadius: 20,
  );
}
