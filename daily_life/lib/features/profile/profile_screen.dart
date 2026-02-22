import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_scaffold.dart';
import 'account_page.dart';
import 'appearance_page.dart';
import 'backup_export_page.dart';
import 'help_support_page.dart';
import 'notifications_page.dart';
import 'profile_notifier.dart';
import 'sync_calendar_page.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _navigate(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => page,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final streak = ref.watch(habitStreakProvider);
    final tasksDone = ref.watch(tasksDonePercentProvider);
    final entries = ref.watch(journalEntryCountProvider);

    return GlassScaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Avatar ──
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glowingBlue, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.glowingBlue.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFF1a3a6e),
                child: Icon(
                  Icons.person,
                  size: 48,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Name (dynamic) ──
            Text(
              profile.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Member since ${profile.memberSince}',
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),

            // ── Stats Row (dynamic) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Habits Streak',
                      value: '$streak',
                      unit: 'Days',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Tasks Done',
                      value: '$tasksDone',
                      unit: '%',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Entries',
                      value: '$entries',
                      unit: '',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Settings List ──
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsItem(
                    icon: Icons.person_outline,
                    label: 'Account',
                    onTap: () => _navigate(context, const AccountPage()),
                  ),
                  const _Divider(),
                  _SettingsItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () => _navigate(context, const NotificationsPage()),
                  ),
                  const _Divider(),
                  _SettingsItem(
                    icon: Icons.palette_outlined,
                    label: 'Appearance',
                    onTap: () => _navigate(context, const AppearancePage()),
                  ),
                  const _Divider(),
                  _SettingsItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Sync Calendar',
                    onTap: () => _navigate(context, const SyncCalendarPage()),
                  ),
                  const _Divider(),
                  _SettingsItem(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () => _navigate(context, const HelpSupportPage()),
                  ),
                  const _Divider(),
                  _SettingsItem(
                    icon: Icons.cloud_download_outlined,
                    label: 'Backup & Export',
                    onTap: () => _navigate(context, const BackupExportPage()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Stat Card (glassmorphism)
// ═══════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
  });
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.glassBorder.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.glowingBlue,
                      ),
                    ),
                    if (unit.isNotEmpty)
                      TextSpan(
                        text: unit,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.glowingBlue,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Settings Item Row
// ═══════════════════════════════════════════════════════════

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.glowingBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.glowingBlue, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Divider
// ═══════════════════════════════════════════════════════════

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
    );
  }
}
