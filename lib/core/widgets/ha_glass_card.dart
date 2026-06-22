import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HAGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final Color? borderColor;
  final VoidCallback? onTap;

  const HAGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.blur = 12,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0x1AFFFFFF), Color(0x08FFFFFF)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xCCFFFFFF), Color(0x99FFFFFF)],
                    ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? (isDark ? HAColors.darkBorder : Colors.white.withOpacity(0.3)),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
