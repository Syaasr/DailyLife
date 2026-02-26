import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_scaffold.dart';
import 'state/journal_notifier.dart';

class JournalEditScreen extends ConsumerStatefulWidget {
  const JournalEditScreen({super.key});

  @override
  ConsumerState<JournalEditScreen> createState() => _JournalEditScreenState();
}

class _JournalEditScreenState extends ConsumerState<JournalEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedTag = 'Gratitude';
  bool _isCustomTag = false;
  final _customTagController = TextEditingController();

  // Local undo/redo for the editing session
  final List<_EditSnapshot> _undoStack = [];
  final List<_EditSnapshot> _redoStack = [];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _customTagController.dispose();
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

  void _save() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    String finalTag = _selectedTag;
    if (_isCustomTag) {
      final custom = _customTagController.text.trim();
      if (custom.isNotEmpty) {
        finalTag = custom;
      } else {
        finalTag = 'General'; // default if left empty
      }
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a title'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    ref.read(journalNotifierProvider.notifier).addEntry(
          title: title,
          content: content,
          tag: finalTag,
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tags = ref
        .read(journalNotifierProvider)
        .tags
        .where((t) => t != 'All')
        .toList();
    if (!tags.contains(_selectedTag) && !_isCustomTag) {
      _selectedTag = tags.isNotEmpty ? tags.first : 'Gratitude';
    }

    return GlassScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Journal'),
      ),
      body: Column(
        children: [
          // Toolbar: undo / redo / save
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
                  onTap: _save,
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

          // Editable content
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

                  // Tag dropdown & text field
                  Row(
                    children: [
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
                            value: _isCustomTag ? 'Custom...' : _selectedTag,
                            dropdownColor: AppColors.deepSapphire,
                            style: const TextStyle(
                              color: AppColors.glowingBlue,
                              fontSize: 14,
                            ),
                            icon: const Icon(
                              Icons.expand_more,
                              color: AppColors.textMuted,
                            ),
                            items: [...tags, 'Custom...'].map((t) {
                              return DropdownMenuItem(value: t, child: Text(t));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                _pushEditUndo();
                                setState(() {
                                  if (val == 'Custom...') {
                                    _isCustomTag = true;
                                  } else {
                                    _isCustomTag = false;
                                    _selectedTag = val;
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      if (_isCustomTag) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.glassBorder.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Center(
                              child: TextField(
                                controller: _customTagController,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'Custom tag name',
                                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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
      ),
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
