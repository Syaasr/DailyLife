import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_scaffold.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon!'),
        backgroundColor: AppColors.glowingBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Header
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.glowingBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline,
                  size: 48,
                  color: AppColors.glowingBlue,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'How can we help you?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Choose an option below to get help',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),

            // FAQ
            _HelpTile(
              icon: Icons.quiz_outlined,
              title: 'FAQ',
              subtitle: 'Find answers to common questions',
              onTap: () => _showComingSoon(context, 'FAQ page'),
            ),
            const SizedBox(height: 12),

            // Contact Support
            _HelpTile(
              icon: Icons.email_outlined,
              title: 'Contact Support',
              subtitle: 'support@dailylife.app',
              onTap: () => _showComingSoon(context, 'Email support'),
            ),
            const SizedBox(height: 12),

            // Report Bug
            _HelpTile(
              icon: Icons.bug_report_outlined,
              title: 'Report a Bug',
              subtitle: 'Help us improve DailyLife',
              onTap: () => _showComingSoon(context, 'Bug report'),
            ),
            const SizedBox(height: 12),

            // Privacy Policy
            _HelpTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              onTap: () => _showComingSoon(context, 'Privacy policy'),
            ),
            const SizedBox(height: 32),

            // App version info
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.glassBorder.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'DailyLife',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Version 0.1.0',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Made with 💙 in Flutter',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
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

class _HelpTile extends StatelessWidget {
  const _HelpTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
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
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
