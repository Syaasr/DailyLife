import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_scaffold.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  int _selectedTag = 0;
  final _tags = ['All', 'Work', 'Personal', 'Health'];

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('To Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // Tag filter
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tags.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final selected = index == _selectedTag;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(_tags[index]),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedTag = index),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Task list
          Expanded(
            child: ListView(
              children: const [
                _TaskCard(
                  name: 'Project Presentation',
                  deadline: 'Due: 5:00 PM',
                  priority: 'High',
                  tag: 'Work',
                  progress: 0.75,
                ),
                _TaskCard(
                  name: 'Grocery Shopping',
                  deadline: 'Due: Tomorrow',
                  priority: 'Medium',
                  tag: 'Personal',
                  progress: 0.3,
                ),
                _TaskCard(
                  name: 'Gym Session',
                  deadline: 'Due: 6:30 PM',
                  priority: 'Low',
                  tag: 'Health',
                  progress: 0.5,
                ),
                _TaskCard(
                  name: 'Code Review',
                  deadline: 'Due: 3:00 PM',
                  priority: 'High',
                  tag: 'Work',
                  progress: 0.9,
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatefulWidget {
  const _TaskCard({
    required this.name,
    required this.deadline,
    required this.priority,
    required this.tag,
    required this.progress,
  });

  final String name;
  final String deadline;
  final String priority;
  final String tag;
  final double progress;

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  bool _expanded = false;

  Color get _priorityColor {
    switch (widget.priority) {
      case 'High':
        return AppColors.error;
      case 'Medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(widget.deadline, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _priorityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.priority,
                  style: TextStyle(color: _priorityColor, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.glowingBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.tag,
                  style: const TextStyle(color: AppColors.glowingBlue, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),

          // Progress bar
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: widget.progress,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(
                widget.progress > 0.7 ? AppColors.error : AppColors.glowingBlue,
              ),
            ),
          ),

          if (_expanded) ...[
            const SizedBox(height: 12),
            Text(
              'This is the expanded description for "${widget.name}". You can add details, notes and more here.',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
