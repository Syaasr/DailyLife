import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'todo_model.dart';

// ═══════════════════════════════════════════════════════════
//  Todo Repository – Hive backed
// ═══════════════════════════════════════════════════════════

class TodoRepository {
  TodoRepository(this._box);

  final Box<TodoTask> _box;

  List<TodoTask> getAll() => _box.values.toList();

  Future<void> put(TodoTask task) async {
    await _box.put(task.id, task);
  }

  Future<void> putAll(List<TodoTask> tasks) async {
    final map = {for (final t in tasks) t.id: t};
    await _box.putAll(map);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  bool get isEmpty => _box.isEmpty;

  /// Seed sample tasks on first launch.
  Future<void> seedIfEmpty() async {
    if (_box.isNotEmpty) return;
    final now = DateTime.now();
    final seeds = [
      TodoTask(
        id: '1',
        name: 'Project Presentation',
        description: 'Prepare the Q1 presentation slides for the team meeting.',
        deadline: now.add(const Duration(hours: 3)),
        priority: TaskPriority.high,
        tag: 'Work',
      ),
      TodoTask(
        id: '2',
        name: 'Grocery Shopping',
        description: 'Buy vegetables, fruits, milk, eggs, and bread.',
        deadline: now.add(const Duration(days: 1)),
        priority: TaskPriority.medium,
        tag: 'Personal',
      ),
      TodoTask(
        id: '3',
        name: 'Gym Session',
        description: 'Upper body workout: bench press, rows, curls.',
        deadline: now.add(const Duration(hours: 5)),
        priority: TaskPriority.low,
        tag: 'Health',
      ),
    ];
    for (final t in seeds) {
      await _box.put(t.id, t);
    }
  }
}

// ── Providers ──

final todoBoxProvider = Provider<Box<TodoTask>>((ref) {
  throw UnimplementedError('todoBoxProvider must be overridden at startup');
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final box = ref.watch(todoBoxProvider);
  return TodoRepository(box);
});
