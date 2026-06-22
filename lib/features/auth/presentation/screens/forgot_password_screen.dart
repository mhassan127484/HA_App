import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_gradient_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.isSuccess && !_emailSent) {
        setState(() => _emailSent = true);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: _emailSent
              ? _buildSuccessView(context)
              : _buildFormView(context, theme, authState),
        ),
      ),
    );
  }

  Widget _buildFormView(
          BuildContext context, ThemeData theme, AuthState authState) =>
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.arrow_back_ios_rounded),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 40),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: HAColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.lock_reset_rounded,
                  color: HAColors.secondary, size: 32),
            ),
            const SizedBox(height: 24),
            Text('Reset password', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Enter your email and we\'ll send you a link to reset your password.',
              style:
                  theme.textTheme.bodyLarge?.copyWith(color: HAColors.slate400),
            ),
            const SizedBox(height: 40),
            AuthTextField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            AuthGradientButton(
              label: 'Send Reset Link',
              isLoading: authState.isLoading,
              onPressed: _handleReset,
            ),
          ],
        ),
      );

  Widget _buildSuccessView(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: HAColors.primaryGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: HAColors.secondary.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(Icons.mark_email_read_outlined,
                color: Colors.white, size: 48),
          ),
          const SizedBox(height: 32),
          Text(
            'Check your inbox',
            style: HATextStyles.h2.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? HAColors.textPrimaryDark
                  : HAColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We sent a reset link to\n${_emailCtrl.text}',
            textAlign: TextAlign.center,
            style: HATextStyles.bodyLarge.copyWith(color: HAColors.slate400),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Back to Sign In'),
            ),
          ),
        ],
      );

  void _handleReset() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authNotifierProvider.notifier)
          .sendPasswordReset(_emailCtrl.text.trim());
    }
  }
}
