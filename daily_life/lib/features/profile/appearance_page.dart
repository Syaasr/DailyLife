import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_scaffold.dart';
import 'profile_notifier.dart';

class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key});

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
        title: const Text('Appearance'),
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
                  Icons.palette_outlined,
                  size: 48,
                  color: AppColors.glowingBlue,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Choose your theme',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),

            // Theme options
            _ThemeOption(
              icon: Icons.dark_mode_rounded,
              title: 'Dark',
              subtitle: 'Deep sapphire blue — the default experience',
              selected: profile.themeMode == ThemeMode.dark,
              onTap: () => notifier.setThemeMode(ThemeMode.dark),
            ),
            const SizedBox(height: 12),
            _ThemeOption(
              icon: Icons.light_mode_rounded,
              title: 'Light',
              subtitle: 'Bright and clean interface',
              selected: profile.themeMode == ThemeMode.light,
              onTap: () => notifier.setThemeMode(ThemeMode.light),
            ),
            const SizedBox(height: 12),
            _ThemeOption(
              icon: Icons.settings_system_daydream_rounded,
              title: 'System',
              subtitle: 'Follow your device settings',
              selected: profile.themeMode == ThemeMode.system,
              onTap: () => notifier.setThemeMode(ThemeMode.system),
            ),
            const SizedBox(height: 32),

            // Color preview
            const Text(
              'Current Palette',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 12),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ColorDot(
                        color: AppColors.deepSapphire,
                        label: 'Primary',
                      ),
                      _ColorDot(color: AppColors.glowingBlue, label: 'Accent'),
                      _ColorDot(color: AppColors.success, label: 'Success'),
                      _ColorDot(color: AppColors.warning, label: 'Warning'),
                      _ColorDot(color: AppColors.error, label: 'Error'),
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

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.glowingBlue.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? AppColors.glowingBlue
                    : AppColors.glassBorder.withValues(alpha: 0.3),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.glowingBlue.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: selected
                        ? AppColors.glowingBlue
                        : AppColors.textMuted,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
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
                if (selected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.glowingBlue,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
      ],
    );
  }
}
