import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_scaffold.dart';
import 'data/journal_entry.dart';
import 'state/journal_notifier.dart';

class JournalDetailScreen extends ConsumerStatefulWidget {
  const JournalDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  ConsumerState<JournalDetailScreen> createState() =>
      _JournalDetailScreenState();
}

class _JournalDetailScreenState extends ConsumerState<JournalDetailScreen> {
  bool _editMode = false;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedTag;

  // Local undo/redo for the text editing session
  final List<_EditSnapshot> _undoStack = [];
  final List<_EditSnapshot> _redoStack = [];

  JournalEntry? _getEntry() {
    final state = ref.read(journalNotifierProvider);
    try {
      return state.entries.firstWhere((e) => e.id == widget.entryId);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _selectedTag = 'Gratitude';

    // Defer reading until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final entry = _getEntry();
      if (entry != null) {
        _titleController.text = entry.title;
        _contentController.text = entry.content;
        setState(() => _selectedTag = entry.tag);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _pushEditUndo() {
    _undoStack.add(_EditSnapshot(
      title: _titleController.text,
      content: _contentController.text,
      tag: _selectedTag,
    ));
    _redoStack.clear();
  }

  void _undoEdit() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_EditSnapshot(
      title: _titleController.text,
      content: _contentController.text,
      tag: _selectedTag,
    ));
    final snapshot = _undoStack.removeLast();
    setState(() {
      _titleController.text = snapshot.title;
      _contentController.text = snapshot.content;
      _selectedTag = snapshot.tag;
    });
  }

  void _redoEdit() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_EditSnapshot(
      title: _titleController.text,
      content: _contentController.text,
      tag: _selectedTag,
    ));
    final snapshot = _redoStack.removeLast();
    setState(() {
      _titleController.text = snapshot.title;
      _contentController.text = snapshot.content;
      _selectedTag = snapshot.tag;
    });
  }

  void _saveChanges() {
    final entry = _getEntry();
    if (entry == null) return;

    final updated = entry.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      tag: _selectedTag,
    );

    ref.read(journalNotifierProvider.notifier).updateEntry(updated);

    setState(() => _editMode = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Journal saved'),
        backgroundColor: AppColors.glowingBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journalState = ref.watch(journalNotifierProvider);
    JournalEntry? entry;
    try {
      entry = journalState.entries.firstWhere((e) => e.id == widget.entryId);
    } catch (_) {
      entry = null;
    }

    if (entry == null) {
      return GlassScaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Journal'),
        ),
        body: const Center(
          child: Text(
            'Journal not found',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        ),
      );
    }

    return GlassScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_editMode ? 'Edit Journal' : 'Journal'),
        actions: [
          IconButton(
            icon: Icon(_editMode ? Icons.visibility : Icons.edit),
            tooltip: _editMode ? 'Read mode' : 'Edit mode',
            onPressed: () {
              if (!_editMode) {
                // Entering edit mode — initialize controllers
                _titleController.text = entry!.title;
                _contentController.text = entry.content;
                _selectedTag = entry.tag;
                _undoStack.clear();
                _redoStack.clear();
              }
              setState(() => _editMode = !_editMode);
            },
          ),
        ],
      ),
      body: _editMode ? _buildEditMode(entry) : _buildReadMode(entry),
    );
  }

  Widget _buildReadMode(JournalEntry entry) {
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(entry.createdAt);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.textMuted.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.glassBorder.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 24),
          Text(
            entry.content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditMode(JournalEntry entry) {
    final tags = ref.read(journalNotifierProvider).tags
        .where((t) => t != 'All')
        .toList();

    return Column(
      children: [
        // Undo / Redo / Save toolbar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              _ToolbarButton(
                icon: Icons.undo,
                enabled: _undoStack.isNotEmpty,
                onTap: _undoEdit,
              ),
              const SizedBox(width: 8),
              _ToolbarButton(
                icon: Icons.redo,
                enabled: _redoStack.isNotEmpty,
                onTap: _redoEdit,
              ),
              const Spacer(),
              GestureDetector(
                onTap: _saveChanges,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.glowingBlue,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.glowingBlue.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Editable fields
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => _pushEditUndo(),
                ),
                const SizedBox(height: 8),

                // Tag dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.glassBorder.withValues(alpha: 0.2),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTag,
                      dropdownColor: AppColors.deepSapphire,
                      style: const TextStyle(
                        color: AppColors.glowingBlue,
                        fontSize: 14,
                      ),
                      icon: const Icon(
                        Icons.expand_more,
                        color: AppColors.textMuted,
                      ),
                      items: tags.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _pushEditUndo();
                          setState(() => _selectedTag = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  height: 1,
                  color: AppColors.glassBorder.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: _contentController,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: null,
                  minLines: 10,
                  decoration: const InputDecoration(
                    hintText: 'Write your thoughts...',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => _pushEditUndo(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: enabled ? 0.12 : 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppColors.glassBorder.withValues(alpha: enabled ? 0.3 : 0.1),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? AppColors.textPrimary
              : AppColors.textMuted.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _EditSnapshot {
  const _EditSnapshot({
    required this.title,
    required this.content,
    required this.tag,
  });

  final String title;
  final String content;
  final String tag;
}
