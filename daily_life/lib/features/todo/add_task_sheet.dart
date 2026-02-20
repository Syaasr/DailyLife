import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'todo_model.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key, this.task});

  /// If non-null, the sheet is in edit mode.
  final TodoTask? task;

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late DateTime _deadline;
  late TaskPriority _priority;
  late String _tag;

  static const _tags = ['Work', 'Personal', 'Health'];

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.task?.name ?? '');
    _descCtrl = TextEditingController(text: widget.task?.description ?? '');
    _deadline =
        widget.task?.deadline ?? DateTime.now().add(const Duration(days: 1));
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _tag = widget.task?.tag ?? 'Personal';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.glowingBlue,
              surface: AppColors.deepSapphireDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.glowingBlue,
              surface: AppColors.deepSapphireDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null || !mounted) return;

    setState(() {
      _deadline =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) return;
    final task = TodoTask(
      id: widget.task?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      deadline: _deadline,
      priority: _priority,
      tag: _tag,
      status: widget.task?.status ?? TaskStatus.pending,
    );
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.deepSapphireDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1),
          left: BorderSide(color: AppColors.glassBorder, width: 1),
          right: BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              _isEdit ? 'Edit Task' : 'New Task',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Name
            _buildField('Task Name', _nameCtrl, 'Enter task name'),
            const SizedBox(height: 14),

            // Description
            _buildField('Description', _descCtrl, 'Enter description',
                maxLines: 3),
            const SizedBox(height: 14),

            // Deadline
            const Text('Deadline',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.glassBorder.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: AppColors.glowingBlue, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      '${_deadline.day}/${_deadline.month}/${_deadline.year}  '
                      '${_deadline.hour.toString().padLeft(2, '0')}:${_deadline.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Priority
            const Text('Priority',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 6),
            Row(
              children: TaskPriority.values.map((p) {
                final selected = p == _priority;
                final color = p == TaskPriority.high
                    ? AppColors.error
                    : p == TaskPriority.medium
                        ? AppColors.warning
                        : AppColors.success;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p.name[0].toUpperCase() + p.name.substring(1)),
                    selected: selected,
                    onSelected: (_) => setState(() => _priority = p),
                    selectedColor: color.withValues(alpha: 0.35),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    labelStyle: TextStyle(
                      color: selected ? color : AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: selected
                          ? color
                          : AppColors.glassBorder.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Tag
            const Text('Tag',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 6),
            Row(
              children: _tags.map((t) {
                final selected = t == _tag;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(t),
                    selected: selected,
                    onSelected: (_) => setState(() => _tag = t),
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
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.glowingBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isEdit ? 'Save Changes' : 'Add Task',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.5), fontSize: 15),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: AppColors.glassBorder.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: AppColors.glassBorder.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.glowingBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
