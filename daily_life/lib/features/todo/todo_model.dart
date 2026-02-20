enum TaskPriority { high, medium, low }

enum TaskStatus { pending, done, skipped }

class TodoTask {
  TodoTask({
    required this.id,
    required this.name,
    this.description = '',
    required this.deadline,
    this.priority = TaskPriority.medium,
    this.tag = 'Personal',
    this.status = TaskStatus.pending,
  });

  final String id;
  final String name;
  final String description;
  final DateTime deadline;
  final TaskPriority priority;
  final String tag;
  final TaskStatus status;

  TodoTask copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? deadline,
    TaskPriority? priority,
    String? tag,
    TaskStatus? status,
  }) {
    return TodoTask(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      tag: tag ?? this.tag,
      status: status ?? this.status,
    );
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  /// Returns 0.0–1.0 representing how close the deadline is.
  /// 1.0 = deadline passed, 0.0 = far away (>7 days).
  double get deadlineProgress {
    final now = DateTime.now();
    if (now.isAfter(deadline)) return 1.0;
    final total = deadline.difference(now).inMinutes;
    // Map 7 days → 0.0, 0 minutes → 1.0
    const maxMinutes = 7 * 24 * 60; // 7 days
    if (total >= maxMinutes) return 0.0;
    return 1.0 - (total / maxMinutes);
  }

  String get deadlineLabel {
    final now = DateTime.now();
    final diff = deadline.difference(now);
    if (diff.isNegative) return 'Overdue';
    if (diff.inMinutes < 60) return 'Due: ${diff.inMinutes}m left';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      return 'Due: ${h}h ${m}m';
    }
    if (diff.inDays == 1) return 'Due: Tomorrow';
    return 'Due: ${diff.inDays} days';
  }
}
