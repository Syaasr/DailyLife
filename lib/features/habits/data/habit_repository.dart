import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit_model.dart';

// ═══════════════════════════════════════════════════════════
//  Habit Repository – Hive backed
// ═══════════════════════════════════════════════════════════

class HabitRepository {
  HabitRepository(this._box);

  final Box<Habit> _box;

  List<Habit> getAll() {
    final habits = _box.values.toList();
    habits.sort((a, b) => a.sortMinutes.compareTo(b.sortMinutes));
    return habits;
  }

  Future<void> put(Habit habit) async {
    await _box.put(habit.id, habit);
  }

  Future<void> putAll(List<Habit> habits) async {
    final map = {for (final h in habits) h.id: h};
    await _box.putAll(map);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  bool get isEmpty => _box.isEmpty;

  /// Seed default habits when box is empty (first launch).
  Future<void> seedIfEmpty() async {
    if (_box.isNotEmpty) return;
    final seeds = [
      Habit(
        id: '1',
        name: 'Morning Yoga',
        time: '07:00',
        place: 'Living Room',
        iconCodePoint: Icons.self_improvement_rounded.codePoint,
      ),
      Habit(
        id: '2',
        name: 'Read 10 Pages',
        time: '08:30',
        place: 'Library',
        iconCodePoint: Icons.menu_book_rounded.codePoint,
      ),
      Habit(
        id: '3',
        name: 'Hydration Goal',
        time: '12:00',
        place: 'Everywhere',
        iconCodePoint: Icons.water_drop_rounded.codePoint,
      ),
    ];
    for (final h in seeds) {
      await _box.put(h.id, h);
    }
  }
}

// ── Providers ──

final habitBoxProvider = Provider<Box<Habit>>((ref) {
  throw UnimplementedError('habitBoxProvider must be overridden at startup');
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final box = ref.watch(habitBoxProvider);
  return HabitRepository(box);
});
