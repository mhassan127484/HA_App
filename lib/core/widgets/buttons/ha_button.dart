import 'package:flutter/material.dart';
import 'package:ha_ecommerce/core/theme/app_theme.dart';

enum HAButtonVariant { primary, outlined, ghost, danger }

class HAButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final HAButtonVariant variant;
  final IconData? leadingIcon;
  final double? width;
  final double height;

  const HAButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = HAButtonVariant.primary,
    this.leadingIcon,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: switch (variant) {
        HAButtonVariant.primary => ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            child: _ButtonContent(label: label, isLoading: isLoading, icon: leadingIcon, isLight: true),
          ),
        HAButtonVariant.outlined => OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            child: _ButtonContent(label: label, isLoading: isLoading, icon: leadingIcon),
          ),
        HAButtonVariant.ghost => TextButton(
            onPressed: isDisabled ? null : onPressed,
            child: _ButtonContent(label: label, isLoading: isLoading, icon: leadingIcon),
          ),
        HAButtonVariant.danger => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.cs.error,
              foregroundColor: Colors.white,
            ),
            onPressed: isDisabled ? null : onPressed,
            child: _ButtonContent(label: label, isLoading: isLoading, icon: leadingIcon, isLight: true),
          ),
      },
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final bool isLoading;
  final IconData? icon;
  final bool isLight;

  const _ButtonContent({
    required this.label,
    required this.isLoading,
    this.icon,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: isLight ? Colors.white : context.cs.primary,
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }
    return Text(label);
  }
}

// ─── Icon button variant ──────────────────────────────────────────────────────
class HAIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double size;
  final bool outlined;

  const HAIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size = 44,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: outlined
          ? BoxDecoration(
              border: Border.all(color: context.cs.outline, width: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.md),
            )
          : null,
      child: IconButton(
        icon: Icon(icon, size: 20, color: color),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
