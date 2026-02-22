import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../habits/providers/habit_provider.dart';
import '../journal/state/journal_notifier.dart';
import '../todo/todo_notifier.dart';

class BackupExportPage extends ConsumerWidget {
  const BackupExportPage({super.key});

  Future<void> _exportJson(BuildContext context, WidgetRef ref) async {
    try {
      final habits = ref.read(habitProvider);
      final todoState = ref.read(todoNotifierProvider);
      final journalState = ref.read(journalNotifierProvider);

      final backup = {
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'habits': habits.map((h) => h.toJson()).toList(),
        'tasks': todoState.tasks
            .map(
              (t) => {
                'id': t.id,
                'name': t.name,
                'description': t.description,
                'deadline': t.deadline.toIso8601String(),
                'priority': t.priority.index,
                'tag': t.tag,
                'status': t.status.index,
              },
            )
            .toList(),
        'journal': journalState.entries
            .map(
              (e) => {
                'id': e.id,
                'title': e.title,
                'content': e.content,
                'tag': e.tag,
                'createdAt': e.createdAt.toIso8601String(),
                'updatedAt': e.updatedAt.toIso8601String(),
              },
            )
            .toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/dailylife_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(jsonString);

      if (!context.mounted) return;

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: 'DailyLife Backup'),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitCount = ref.watch(habitProvider).length;
    final taskCount = ref.watch(todoNotifierProvider).tasks.length;
    final entryCount = ref.watch(journalNotifierProvider).entries.length;

    return GlassScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Backup & Export'),
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
                  Icons.cloud_download_outlined,
                  size: 48,
                  color: AppColors.glowingBlue,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Your Data, Your Control',
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
                'Export all your data as a JSON file.\nYou can save it to Files or share it.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // Data summary
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.glassBorder.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Data Summary',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SummaryRow(
                        icon: Icons.loop_rounded,
                        label: 'Habits',
                        count: habitCount,
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        icon: Icons.check_circle_outline,
                        label: 'Tasks',
                        count: taskCount,
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        icon: Icons.book_outlined,
                        label: 'Journal Entries',
                        count: entryCount,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Export button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _exportJson(context, ref),
                icon: const Icon(Icons.file_download_outlined),
                label: const Text(
                  'Export as JSON',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.glowingBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Info card
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
                          'All data is stored locally on your device. '
                          'Exporting creates a JSON backup you can keep safe.',
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.count,
  });
  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.glowingBlue, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
