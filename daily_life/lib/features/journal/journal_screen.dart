import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/edit_mode_toolbar.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../habits/providers/habit_provider.dart';
import 'data/journal_entry.dart';
import 'journal_detail_screen.dart';
import 'journal_edit_screen.dart';
import 'state/journal_notifier.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditPicker(List<JournalEntry> entries) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.deepSapphireDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title:
            const Text('Edit Journal', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: entries.length,
            itemBuilder: (ctx, i) => ListTile(
              leading: const Icon(Icons.edit_outlined,
                  color: AppColors.glowingBlue),
              title: Text(entries[i].title,
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(entries[i].tag,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        JournalDetailScreen(entryId: entries[i].id),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showDeletePicker(
      List<JournalEntry> entries, JournalNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.deepSapphireDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Delete Journal',
            style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: entries.length,
            itemBuilder: (ctx, i) => ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(entries[i].title,
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(entries[i].tag,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
              onTap: () {
                notifier.deleteEntry(entries[i].id);
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
    final journalState = ref.watch(journalNotifierProvider);
    final notifier = ref.read(journalNotifierProvider.notifier);
    final devMode = ref.watch(devModeProvider);
    final filtered = journalState.filteredEntries;

    return GlassScaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'journal_fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const JournalEditScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Journal'),
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
            onPressed: () =>
                ref.read(devModeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.glassBorder.withValues(alpha: 0.2),
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (query) => notifier.setSearch(query),
                decoration: const InputDecoration(
                  hintText: 'Search journals...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tag filter
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: journalState.tags.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final tag = journalState.tags[index];
                final selected = tag == journalState.selectedTag;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(tag),
                    selected: selected,
                    onSelected: (_) => notifier.setTag(tag),
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Edit-Mode Toolbar (shared widget) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: EditModeToolbar(
              visible: devMode,
              actions: [
                EditModeAction(
                  icon: Icons.undo,
                  label: 'Undo',
                  enabled: notifier.canUndo,
                  onTap: () => notifier.undo(),
                ),
                EditModeAction(
                  icon: Icons.redo,
                  label: 'Redo',
                  enabled: notifier.canRedo,
                  onTap: () => notifier.redo(),
                ),
                EditModeAction(
                  icon: Icons.add_circle_outline,
                  label: 'Add',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const JournalEditScreen()),
                    );
                  },
                ),
                EditModeAction(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  enabled: filtered.isNotEmpty,
                  onTap: () => _showEditPicker(filtered),
                ),
                EditModeAction(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  enabled: filtered.isNotEmpty,
                  onTap: () => _showDeletePicker(filtered, notifier),
                ),
              ],
            ),
          ),

          // Journal list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: AppColors.textMuted.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          journalState.searchQuery.isNotEmpty
                              ? 'No journals found'
                              : 'Start writing your journal',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length + 1,
                    itemBuilder: (context, index) {
                      if (index == filtered.length) {
                        return const SizedBox(height: 100);
                      }
                      final entry = filtered[index];
                      return _JournalCard(
                        entry: entry,
                        devMode: devMode,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  JournalDetailScreen(entryId: entry.id),
                            ),
                          );
                        },
                        onDelete: () => notifier.deleteEntry(entry.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}



class _JournalCard extends StatelessWidget {
  const _JournalCard({
    required this.entry,
    required this.devMode,
    required this.onTap,
    required this.onDelete,
  });

  final JournalEntry entry;
  final bool devMode;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d').format(entry.createdAt);
    final preview = entry.content.length > 100
        ? '${entry.content.substring(0, 100)}...'
        : entry.content;

    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              if (devMode) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.deepSapphire,
                        title: const Text(
                          'Delete Journal?',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          'This action can be undone in dev mode.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onDelete();
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.glowingBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              entry.tag,
              style: const TextStyle(
                color: AppColors.glowingBlue,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
