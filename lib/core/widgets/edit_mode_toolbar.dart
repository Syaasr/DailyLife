import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════
//  Reusable Edit-Mode Toolbar
//  — same design across Habits, To-Do, and Journal tabs
// ═══════════════════════════════════════════════════════════

/// A single action button inside the toolbar.
class EditModeAction {
  const EditModeAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
}

/// Reusable edit-mode toolbar with consistent styling.
/// Renders as a blue-tinted pill with icon buttons.
class EditModeToolbar extends StatelessWidget {
  const EditModeToolbar({
    super.key,
    required this.visible,
    required this.actions,
  });

  final bool visible;
  final List<EditModeAction> actions;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.glowingBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.glowingBlue.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((a) {
          return _EditModeIcon(
            icon: a.icon,
            label: a.label,
            enabled: a.enabled,
            onTap: a.onTap,
          );
        }).toList(),
      ),
    );
  }
}

/// Single icon + label inside the toolbar.
class _EditModeIcon extends StatelessWidget {
  const _EditModeIcon({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? AppColors.glowingBlue
        : AppColors.textMuted.withValues(alpha: 0.3);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
