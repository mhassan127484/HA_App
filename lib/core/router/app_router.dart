import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_products_screen.dart';
import '../../features/admin/presentation/screens/admin_orders_screen.dart';
import '../../features/admin/presentation/screens/admin_add_product_screen.dart';
import '../widgets/main_scaffold.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    debugLogDiagnostics: true,
    initialLocation: '/home',

    redirect: (context, state) {
      final isLoading = authState.isLoading;
      if (isLoading) return null;

      final user = authState.value;
      final isAuthenticated = user != null;
      final isEmailVerified = user?.isEmailVerified ?? false;
      final path = state.matchedLocation;

      final authPaths = ['/login', '/register', '/forgot-password'];
      final isOnAuthPath = authPaths.contains(path);

      if (!isAuthenticated && !isOnAuthPath) return '/login';
      if (isAuthenticated && !isEmailVerified && path != '/verify-email') return '/verify-email';
      if (isAuthenticated && isEmailVerified && isOnAuthPath) {
        return user.isAdmin ? '/admin' : '/home';
      }
      return null;
    },

    routes: [
      // ── Auth Routes ──────────────────────────────────────────────
      GoRoute(
        path: '/login',
        pageBuilder: (ctx, state) => _fadeTransition(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (ctx, state) => _slideTransition(state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (ctx, state) => _slideTransition(state, const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: '/verify-email',
        pageBuilder: (ctx, state) => _fadeTransition(state, const EmailVerificationScreen()),
      ),

      // ── User Shell Routes (bottom nav) ───────────────────────────
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (ctx, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (ctx, state) => _noTransition(state, const HomeScreen()),
          ),
          GoRoute(
            path: '/products',
            pageBuilder: (ctx, state) => _noTransition(state, const ProductListScreen()),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootKey,
                pageBuilder: (ctx, state) => _slideTransition(
                  state,
                  ProductDetailScreen(productId: state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/cart',
            pageBuilder: (ctx, state) => _noTransition(state, const CartScreen()),
          ),
          GoRoute(
            path: '/orders',
            pageBuilder: (ctx, state) => _noTransition(state, const OrdersScreen()),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootKey,
                pageBuilder: (ctx, state) => _slideTransition(
                  state,
                  OrderDetailScreen(orderId: state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (ctx, state) => _noTransition(state, const ProfileScreen()),
          ),
        ],
      ),

      // ── Checkout (full screen) ───────────────────────────────────
      GoRoute(
        path: '/checkout',
        parentNavigatorKey: _rootKey,
        pageBuilder: (ctx, state) => _slideTransition(state, const CheckoutScreen()),
      ),

      // ── Admin Shell Routes ───────────────────────────────────────
      GoRoute(
        path: '/admin',
        pageBuilder: (ctx, state) => _fadeTransition(state, const AdminDashboardScreen()),
        routes: [
          GoRoute(
            path: 'products',
            pageBuilder: (ctx, state) => _slideTransition(state, const AdminProductsScreen()),
            routes: [
              GoRoute(
                path: 'add',
                pageBuilder: (ctx, state) => _slideTransition(state, const AdminAddProductScreen()),
              ),
              GoRoute(
                path: 'edit/:id',
                pageBuilder: (ctx, state) => _slideTransition(
                  state,
                  AdminAddProductScreen(productId: state.pathParameters['id']),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'orders',
            pageBuilder: (ctx, state) => _slideTransition(state, const AdminOrdersScreen()),
          ),
        ],
      ),
    ],

    errorBuilder: (ctx, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found', style: Theme.of(ctx).textTheme.headlineSmall),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ctx.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

CustomTransitionPage _fadeTransition(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, anim, __, c) => FadeTransition(opacity: anim, child: c),
    );

CustomTransitionPage _slideTransition(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, anim, __, c) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: c,
      ),
    );

CustomTransitionPage _noTransition(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, __, ___, c) => c,
    );
