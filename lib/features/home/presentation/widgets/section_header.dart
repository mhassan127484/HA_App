import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String seeAllLabel;
  final VoidCallback? onSeeAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.seeAllLabel = 'See all',
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: HATextStyles.h4.copyWith(
            color: isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: [
                Text(
                  seeAllLabel,
                  style: HATextStyles.labelMedium.copyWith(color: HAColors.secondary),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: HAColors.secondary),
              ],
            ),
          ),
      ],
    );
  }
}
