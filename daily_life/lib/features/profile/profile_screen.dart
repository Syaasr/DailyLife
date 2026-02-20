import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Avatar
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
                child: Icon(Icons.person, size: 48, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Alex Doe',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'Member since 2023',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),

            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _StatCard(label: 'Habits Streak', value: '12', unit: 'Days')),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Tasks Done', value: '85', unit: '%')),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Entries', value: '42', unit: '')),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings list
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: const [
                  _SettingsItem(icon: Icons.person_outline, label: 'Account'),
                  _Divider(),
                  _SettingsItem(icon: Icons.notifications_outlined, label: 'Notifications'),
                  _Divider(),
                  _SettingsItem(icon: Icons.palette_outlined, label: 'Appearance'),
                  _Divider(),
                  _SettingsItem(icon: Icons.calendar_today_outlined, label: 'Sync Calendar'),
                  _Divider(),
                  _SettingsItem(icon: Icons.help_outline, label: 'Help & Support'),
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.unit});
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
            border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.glowingBlue),
                    ),
                    TextSpan(
                      text: unit,
                      style: const TextStyle(fontSize: 14, color: AppColors.glowingBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 15, color: Colors.white)),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

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
