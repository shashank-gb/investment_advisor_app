import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ProfileHeader(user: user),
            const SizedBox(height: 20),
            _InfoSection(user: user),
            const SizedBox(height: 20),
            _SettingsSection(),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout, color: AppColors.negative),
              label: const Text('Sign Out', style: TextStyle(color: AppColors.negative)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: BorderSide(color: AppColors.negative.withValues(alpha: 0.5)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${AppConfig.appName} v1.0.0',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  _KycBadge(status: user.kycStatus),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KycBadge extends StatelessWidget {
  const _KycBadge({required this.status});

  final KycStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      KycStatus.verified => (AppColors.positive, Icons.verified_user),
      KycStatus.pending => (AppColors.warning, Icons.pending),
      KycStatus.rejected => (AppColors.negative, Icons.error_outline),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            'KYC ${status.label}',
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _InfoTile(icon: Icons.phone_outlined, label: 'Phone', value: user.phone ?? 'Not added'),
          const Divider(height: 1, indent: 56),
          _InfoTile(icon: Icons.badge_outlined, label: 'PAN', value: user.pan ?? 'Not verified'),
          const Divider(height: 1, indent: 56),
          _InfoTile(
            icon: Icons.calendar_today_outlined,
            label: 'Member since',
            value: user.createdAt != null
                ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                : '—',
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.security, color: AppColors.primary),
            title: const Text('Security & Privacy'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.primary),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(Icons.description_outlined, color: AppColors.primary),
            title: const Text('Terms & Disclosures'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
