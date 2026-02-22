import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(icon: Icons.grid_view_rounded, label: 'Habits'),
    _NavItem(icon: Icons.checklist_rounded, label: 'Tasks'),
    _NavItem(icon: Icons.book_rounded, label: 'Journal'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Thin white divider on top
        Divider(
          height: 0.5,
          thickness: 0.5,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        // Full-width dark nav bar
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 70,
              width: double.infinity,
              color: AppColors.deepSapphireDark.withValues(alpha: 0.92),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_items.length, (i) {
                    final selected = i == currentIndex;
                    return _NavButton(
                      item: _items[i],
                      selected: selected,
                      onTap: () => onTap(i),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: selected ? AppColors.glowingBlue : AppColors.textMuted,
              size: 24,
              shadows: selected
                  ? [
                      Shadow(
                        color: AppColors.glowingBlue.withValues(alpha: 0.6),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: selected ? AppColors.glowingBlue : AppColors.textMuted,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
