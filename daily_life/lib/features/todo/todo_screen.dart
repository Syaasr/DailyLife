import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/edit_mode_toolbar.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../habits/providers/habit_provider.dart';
import 'add_task_sheet.dart';
import 'todo_model.dart';
import 'todo_notifier.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  final Set<String> _selectedIds = {};

  Future<void> _openAddSheet({TodoTask? task}) async {
    final todoState = ref.read(todoNotifierProvider);
    // Collect existing tags (excluding 'All')
    final existingTags = todoState.dynamicTags.where((t) => t != 'All').toList();

    final result = await showModalBottomSheet<TodoTask>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheet(task: task, existingTags: existingTags),
    );
    if (result == null) return;
    if (task != null) {
      ref.read(todoNotifierProvider.notifier).editTask(result);
    } else {
      ref.read(todoNotifierProvider.notifier).addTask(result);
    }
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _deleteSelected() {
    ref.read(todoNotifierProvider.notifier).deleteTasks(_selectedIds.toList());
    setState(() => _selectedIds.clear());
  }

  void _showEditPicker(List<TodoTask> tasks) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.deepSapphireDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Edit Task', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tasks.length,
            itemBuilder: (ctx, i) => ListTile(
              leading: const Icon(Icons.edit_outlined,
                  color: AppColors.glowingBlue),
              title: Text(tasks[i].name,
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(tasks[i].tag,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _openAddSheet(task: tasks[i]);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showDeletePicker(List<TodoTask> tasks) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.deepSapphireDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title:
            const Text('Delete Task', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tasks.length,
            itemBuilder: (ctx, i) => ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(tasks[i].name,
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(tasks[i].tag,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
              onTap: () {
                ref
                    .read(todoNotifierProvider.notifier)
                    .deleteTask(tasks[i].id);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoNotifierProvider);
    final devMode = ref.watch(devModeProvider);
    final notifier = ref.read(todoNotifierProvider.notifier);
    final filteredTasks = todoState.filteredTasks;
    final tags = todoState.dynamicTags;

    // Clear selections when edit mode is turned off
    if (!devMode && _selectedIds.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedIds.clear());
      });
    }

    return GlassScaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'todo_fab',
        onPressed: () => _openAddSheet(),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('To Do List'),
        actions: [
          if (devMode)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                'Edit Mode',
                style: TextStyle(
                  color: AppColors.glowingBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              devMode ? Icons.settings_rounded : Icons.settings_outlined,
              color: devMode ? AppColors.glowingBlue : AppColors.textPrimary,
            ),
            onPressed: () => ref.read(devModeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Edit-Mode Toolbar (shared widget) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: EditModeToolbar(
              visible: devMode,
              actions: [
                EditModeAction(
                  icon: Icons.undo,
                  label: 'Undo',
                  enabled: notifier.canUndo,
                  onTap: notifier.undo,
                ),
                EditModeAction(
                  icon: Icons.redo,
                  label: 'Redo',
                  enabled: notifier.canRedo,
                  onTap: notifier.redo,
                ),
                EditModeAction(
                  icon: Icons.add_circle_outline,
                  label: 'Add',
                  onTap: () => _openAddSheet(),
                ),
                EditModeAction(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  enabled: filteredTasks.isNotEmpty,
                  onTap: () => _showEditPicker(filteredTasks),
                ),
                if (_selectedIds.isNotEmpty)
                  EditModeAction(
                    icon: Icons.delete_outline,
                    label: 'Del (${_selectedIds.length})',
                    onTap: _deleteSelected,
                  )
                else
                  EditModeAction(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    enabled: filteredTasks.isNotEmpty,
                    onTap: () => _showDeletePicker(filteredTasks),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // ── Tag Filter (horizontal scroll, dynamic) ──
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tags.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final tag = tags[index];
                final selected = tag == todoState.selectedTag;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(tag),
                    selected: selected,
                    onSelected: (_) => notifier.selectTag(tag),
                    selectedColor: AppColors.glowingBlue,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textMuted,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: selected
                          ? AppColors.glowingBlue
                          : AppColors.glassBorder.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Task List ──
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 64,
                            color: AppColors.textMuted.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        const Text('No tasks here!',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTasks.length + 1, // +1 for bottom space
                    itemBuilder: (context, index) {
                      if (index == filteredTasks.length) {
                        return const SizedBox(height: 100);
                      }
                      final task = filteredTasks[index];
                      final isSelected = _selectedIds.contains(task.id);
                      return _SwipeableTaskCard(
                        task: task,
                        devMode: devMode,
                        isSelected: isSelected,
                        onDone: () => notifier.markDone(task.id),
                        onSkip: () => notifier.markSkipped(task.id),
                        onEdit: () => _openAddSheet(task: task),
                        onDelete: () => notifier.deleteTask(task.id),
                        onLongPress: devMode
                            ? () => _toggleSelect(task.id)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


// ──────────────────────────────────────────────
// Swipeable Task Card with multi-select support
// ──────────────────────────────────────────────

class _SwipeableTaskCard extends StatefulWidget {
  const _SwipeableTaskCard({
    required this.task,
    required this.devMode,
    required this.isSelected,
    required this.onDone,
    required this.onSkip,
    required this.onEdit,
    required this.onDelete,
    this.onLongPress,
  });

  final TodoTask task;
  final bool devMode;
  final bool isSelected;
  final VoidCallback onDone;
  final VoidCallback onSkip;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onLongPress;

  @override
  State<_SwipeableTaskCard> createState() => _SwipeableTaskCardState();
}

class _SwipeableTaskCardState extends State<_SwipeableTaskCard> {
  bool _expanded = false;

  Color get _priorityColor {
    switch (widget.task.priority) {
      case TaskPriority.high:
        return AppColors.error;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.low:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.task.id),
      // Swipe LEFT → Done (green)
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 32),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 8),
            Text('Done',
                style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ],
        ),
      ),
      // Swipe RIGHT → Skip (yellow)
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 32),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Skip',
                style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            SizedBox(width: 8),
            Icon(Icons.skip_next_rounded, color: AppColors.warning, size: 28),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          widget.onDone();
        } else {
          widget.onSkip();
        }
        return false;
      },
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        child: GlassCard(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            decoration: widget.isSelected
                ? BoxDecoration(
                    border: Border.all(
                      color: AppColors.glowingBlue,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Selection indicator
                    if (widget.devMode)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          widget.isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: widget.isSelected
                              ? AppColors.glowingBlue
                              : AppColors.textMuted.withValues(alpha: 0.4),
                          size: 22,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.task.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(widget.task.deadlineLabel,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _priorityColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.task.priorityLabel,
                        style: TextStyle(
                            color: _priorityColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.glowingBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.task.tag,
                        style: const TextStyle(
                            color: AppColors.glowingBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),

                // Deadline progress bar
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: widget.task.deadlineProgress,
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(
                      widget.task.deadlineProgress > 0.7
                          ? AppColors.error
                          : AppColors.glowingBlue,
                    ),
                  ),
                ),

                // Expandable description
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.task.description.isNotEmpty
                              ? widget.task.description
                              : 'No description.',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                        if (widget.devMode) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _SmallActionButton(
                                icon: Icons.edit,
                                label: 'Edit',
                                color: AppColors.glowingBlue,
                                onTap: widget.onEdit,
                              ),
                              const SizedBox(width: 12),
                              _SmallActionButton(
                                icon: Icons.delete_outline,
                                label: 'Delete',
                                color: AppColors.error,
                                onTap: widget.onDelete,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Small action button (edit / delete in dev mode)
// ──────────────────────────────────────────────

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
