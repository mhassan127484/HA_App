import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Profile header with gradient
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    HAColors.primary,
                    HAColors.secondary.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: userAsync.when(
                    loading: () => const _ProfileHeaderSkeleton(),
                    error: (_, __) => const _ProfileHeaderSkeleton(),
                    data: (user) => user == null
                        ? const _ProfileHeaderSkeleton()
                        : _ProfileHeader(user: user),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Section
                  const _SectionLabel('Account'),
                  _SettingsCard(children: [
                    _SettingsItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Edit Profile',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.location_on_outlined,
                      label: 'Saved Addresses',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      trailing: Switch.adaptive(
                        value: true,
                        onChanged: (_) {},
                        activeColor: HAColors.secondary,
                      ),
                      onTap: null,
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Preferences Section
                  const _SectionLabel('Preferences'),
                  _SettingsCard(children: [
                    _SettingsItem(
                      icon: isDark
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      label: 'Dark Mode',
                      trailing: Switch.adaptive(
                        value: isDark,
                        onChanged: (val) {
                          ref.read(themeModeProvider.notifier).state =
                              val ? ThemeMode.dark : ThemeMode.light;
                        },
                        activeColor: HAColors.secondary,
                      ),
                      onTap: null,
                    ),
                    _SettingsItem(
                      icon: Icons.language_outlined,
                      label: 'Language',
                      value: 'English',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.attach_money_rounded,
                      label: 'Currency',
                      value: 'USD',
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Support Section
                  const _SectionLabel('Support'),
                  _SettingsCard(children: [
                    _SettingsItem(
                      icon: Icons.help_outline_rounded,
                      label: 'Help & Support',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.policy_outlined,
                      label: 'Privacy Policy',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.description_outlined,
                      label: 'Terms of Service',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.info_outline_rounded,
                      label: 'About',
                      value: 'v1.0.0',
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Sign Out
                  _SettingsCard(children: [
                    _SettingsItem(
                      icon: Icons.logout_rounded,
                      label: 'Sign Out',
                      labelColor: HAColors.error,
                      iconColor: HAColors.error,
                      showChevron: false,
                      onTap: () => _showSignOutDialog(context, ref),
                    ),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            child:
                const Text('Sign Out', style: TextStyle(color: HAColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.4), width: 2),
          ),
          child: ClipOval(
            child: user.photoUrl != null
                ? CachedNetworkImage(
                    imageUrl: user.photoUrl!, fit: BoxFit.cover)
                : Container(
                    color: Colors.white.withValues(alpha: 0.15),
                    child: Center(
                      child: Text(
                        (user.displayName?.isNotEmpty == true
                                ? user.displayName![0]
                                : user.email[0])
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName ?? 'User',
                style: HATextStyles.h3.copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                user.email,
                style: HATextStyles.bodySmall
                    .copyWith(color: Colors.white.withValues(alpha: 0.8)),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              _RoleBadge(role: user.role),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Text(
        role.toUpperCase(),
        style: HATextStyles.labelSmall.copyWith(
          color: Colors.white,
          letterSpacing: 1.2,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _ProfileHeaderSkeleton extends StatelessWidget {
  const _ProfileHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 120,
                height: 18,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 6),
            Container(
                width: 180,
                height: 14,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4))),
          ],
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: HATextStyles.labelSmall.copyWith(
          letterSpacing: 1.5,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? HAColors.darkSurface : HAColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final i = entry.key;
          final child = entry.value;
          return Column(
            children: [
              child,
              if (i < children.length - 1)
                Divider(
                    height: 1,
                    indent: 52,
                    color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? labelColor;
  final Color? iconColor;
  final bool showChevron;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
    this.labelColor,
    this.iconColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (iconColor ?? HAColors.secondary).withValues(alpha: 0.1),
        ),
        child: Icon(icon, size: 18, color: iconColor ?? HAColors.secondary),
      ),
      title: Text(
        label,
        style: HATextStyles.bodyMedium.copyWith(
          color: labelColor ?? Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ??
          (value != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(value!,
                        style: HATextStyles.bodySmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        )),
                    if (showChevron) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded,
                          size: 18,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.3)),
                    ],
                  ],
                )
              : showChevron
                  ? Icon(Icons.chevron_right_rounded,
                      size: 18,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.3))
                  : null),
    );
  }
}
