import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TutorialDialog extends StatelessWidget {
  const TutorialDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.deepSapphireDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text('How to use DailyLife', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Section(
              icon: Icons.spa_outlined,
              title: 'Habit Tracker',
              text: '• Swipe a habit Left to mark it Done.\n• Swipe Right to Skip it.\n• Tap the Calendar icon or the pill dates to view history.\n• Click "Edit Mode" (gear icon) to Add, Edit, or Delete habits.',
            ),
            SizedBox(height: 16),
            _Section(
              icon: Icons.check_circle_outline,
              title: 'To Do List',
              text: '• Tap the + button to add a quick task.\n• Select predefined or custom tags for organization.\n• Click a task to expand it and read the description.\n• Long-press or use Edit Mode to delete tasks.',
            ),
            SizedBox(height: 16),
            _Section(
              icon: Icons.book_outlined,
              title: 'Journal',
              text: '• Tap the + button to create a new entry.\n• Add tags (including custom ones) to organize your thoughts.\n• Use the filter button at the top to sort by tags.\n• Swipe entries to edit or delete in Edit Mode.',
            ),
            SizedBox(height: 16),
            _Section(
              icon: Icons.undo,
              title: 'Undo & Redo',
              text: 'Made a mistake? In Edit Mode, you can easily Undo or Redo your previous actions across all tabs.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it!', style: TextStyle(color: AppColors.glowingBlue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.glowingBlue, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: AppColors.glowingBlue, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }
}
