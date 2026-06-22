import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_gradient_button.dart';
import '../widgets/social_divider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.isSuccess && next.user != null) {
        if (next.user!.isAdmin) {
          context.go('/admin');
        } else {
          context.go('/home');
        }
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: HAColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [HAColors.darkBg, HAColors.darkSurface],
                )
              : null,
          color: isDark ? null : HAColors.lightBg,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      _buildLogo(isDark),
                      const SizedBox(height: 48),
                      _buildHeader(theme),
                      const SizedBox(height: 40),
                      _buildEmailField(),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 16),
                      _buildForgotPassword(),
                      const SizedBox(height: 32),
                      AuthGradientButton(
                        label: 'Sign In',
                        isLoading: authState.isLoading,
                        onPressed: _handleSignIn,
                      ),
                      const SizedBox(height: 24),
                      const SocialDivider(label: 'or'),
                      const SizedBox(height: 24),
                      _buildRegisterLink(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) => Row(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: HAColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: HAColors.secondary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 26),
      ),
      const SizedBox(width: 12),
      Text(
        'HA Store',
        style: HATextStyles.h3.copyWith(
          color: isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight,
          letterSpacing: -0.5,
        ),
      ),
    ],
  );

  Widget _buildHeader(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Welcome back', style: theme.textTheme.headlineMedium),
      const SizedBox(height: 8),
      Text(
        'Sign in to continue shopping',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.brightness == Brightness.dark
              ? HAColors.textSecondaryDark
              : HAColors.textSecondaryLight,
        ),
      ),
    ],
  );

  Widget _buildEmailField() => AuthTextField(
    controller: _emailCtrl,
    label: 'Email',
    hint: 'you@example.com',
    keyboardType: TextInputType.emailAddress,
    prefixIcon: Icons.email_outlined,
    validator: (v) {
      if (v == null || v.isEmpty) return 'Email is required';
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Enter a valid email';
      return null;
    },
  );

  Widget _buildPasswordField() => AuthTextField(
    controller: _passwordCtrl,
    label: 'Password',
    hint: '••••••••',
    obscureText: _obscurePassword,
    prefixIcon: Icons.lock_outline_rounded,
    suffixIcon: IconButton(
      icon: Icon(
        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: HAColors.slate400,
        size: 20,
      ),
      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
    ),
    validator: (v) {
      if (v == null || v.isEmpty) return 'Password is required';
      if (v.length < 6) return 'Password must be at least 6 characters';
      return null;
    },
  );

  Widget _buildForgotPassword() => Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: () => context.push('/forgot-password'),
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      child: Text(
        'Forgot password?',
        style: HATextStyles.labelMedium.copyWith(color: HAColors.secondary),
      ),
    ),
  );

  Widget _buildRegisterLink(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Don't have an account? ",
        style: HATextStyles.bodyMedium.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? HAColors.textSecondaryDark
              : HAColors.textSecondaryLight,
        ),
      ),
      GestureDetector(
        onTap: () => context.go('/register'),
        child: Text(
          'Create one',
          style: HATextStyles.labelMedium.copyWith(color: HAColors.secondary),
        ),
      ),
    ],
  );

  void _handleSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).signIn(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
    }
  }
}
