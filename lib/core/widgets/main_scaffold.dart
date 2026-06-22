import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  static const _tabs = [
    _NavTab(path: '/home',     icon: Icons.home_outlined,          activeIcon: Icons.home_rounded,           label: 'Home'),
    _NavTab(path: '/products', icon: Icons.grid_view_outlined,     activeIcon: Icons.grid_view_rounded,      label: 'Explore'),
    _NavTab(path: '/cart',     icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart_rounded,  label: 'Cart'),
    _NavTab(path: '/orders',   icon: Icons.receipt_long_outlined,  activeIcon: Icons.receipt_long_rounded,   label: 'Orders'),
    _NavTab(path: '/profile',  icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,         label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = _tabs.indexWhere((t) => location.startsWith(t.path));
    if (currentIndex < 0) currentIndex = 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? HAColors.darkSurface : HAColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? HAColors.darkBorder : HAColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: _tabs.asMap().entries.map((e) {
                final idx = e.key;
                final tab = e.value;
                final isSelected = idx == currentIndex;

                Widget icon = Icon(
                  isSelected ? tab.activeIcon : tab.icon,
                  size: 24,
                  color: isSelected ? HAColors.secondary : HAColors.slate400,
                );

                if (tab.path == '/cart' && cartCount > 0) {
                  icon = badges.Badge(
                    badgeContent: Text(
                      cartCount > 99 ? '99+' : cartCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                    ),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: HAColors.error,
                      padding: EdgeInsets.all(4),
                    ),
                    child: icon,
                  );
                }

                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.go(tab.path),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: icon,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: HATextStyles.labelSmall.copyWith(
                            color: isSelected ? HAColors.secondary : HAColors.slate400,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavTab({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
