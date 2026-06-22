import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SocialDivider extends StatelessWidget {
  final String label;
  const SocialDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? HAColors.darkBorder : HAColors.lightBorder;

    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: HATextStyles.bodySmall.copyWith(
              color: isDark ? HAColors.textTertiaryDark : HAColors.textTertiaryLight,
            ),
          ),
        ),
        Expanded(child: Divider(color: dividerColor, thickness: 1)),
      ],
    );
  }
}
