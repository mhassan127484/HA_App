import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  Timer? _checkTimer;
  bool _canResend = false;
  int _countdown = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
    _startResendCountdown();
  }

  void _startVerificationCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
        _checkTimer?.cancel();
        if (mounted) context.go('/home');
      }
    });
  }

  void _startResendCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: HAColors.primaryGradient,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: HAColors.secondary.withValues(alpha: 0.35),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: const Icon(Icons.mark_email_unread_rounded,
                    color: Colors.white, size: 56),
              ),
              const SizedBox(height: 40),
              Text(
                'Verify your email',
                style: HATextStyles.h2.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? HAColors.textPrimaryDark
                      : HAColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a verification link to\n$email',
                textAlign: TextAlign.center,
                style:
                    HATextStyles.bodyLarge.copyWith(color: HAColors.slate400),
              ),
              const SizedBox(height: 12),
              Text(
                'Click the link in the email to verify your account. This page updates automatically.',
                textAlign: TextAlign.center,
                style:
                    HATextStyles.bodySmall.copyWith(color: HAColors.slate500),
              ),
              const Spacer(),
              _buildResendButton(authState),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (mounted) context.go('/login');
                },
                child: Text(
                  'Use a different account',
                  style: HATextStyles.labelMedium
                      .copyWith(color: HAColors.slate400),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton(AuthState authState) => SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: _canResend && !authState.isLoading ? _handleResend : null,
          child: authState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: HAColors.secondary),
                )
              : Text(
                  _canResend
                      ? 'Resend verification email'
                      : 'Resend in ${_countdown}s',
                ),
        ),
      );

  void _handleResend() async {
    final success =
        await ref.read(authNotifierProvider.notifier).resendVerification();
    if (success) {
      setState(() {
        _canResend = false;
        _countdown = 60;
      });
      _startResendCountdown();
    }
  }
}
