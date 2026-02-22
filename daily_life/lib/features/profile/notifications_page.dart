import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_scaffold.dart';
import 'profile_notifier.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return GlassScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Header icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.glowingBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  size: 48,
                  color: AppColors.glowingBlue,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Manage your notifications',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),

            // Daily Reminders
            _NotificationTile(
              icon: Icons.alarm_rounded,
              title: 'Daily Reminders',
              subtitle: 'Get reminded to complete your habits every day',
              value: profile.dailyReminders,
              onChanged: (_) => notifier.toggleDailyReminders(),
            ),
            const SizedBox(height: 12),

            // Achievement Alerts
            _NotificationTile(
              icon: Icons.emoji_events_rounded,
              title: 'Achievement Alerts',
              subtitle: 'Celebrate when you reach milestones',
              value: profile.achievementAlerts,
              onChanged: (_) => notifier.toggleAchievementAlerts(),
            ),
            const SizedBox(height: 32),

            // Info
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.glassBorder.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.glowingBlue,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notification preferences are stored locally on this device.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.glassBorder.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.glowingBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.glowingBlue, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.glowingBlue,
                activeTrackColor: AppColors.glowingBlue.withValues(alpha: 0.4),
                inactiveThumbColor: AppColors.textMuted,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
