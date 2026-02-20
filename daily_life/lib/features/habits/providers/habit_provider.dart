import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit_model.dart';

// ── Dev Mode ──────────────────────────────────────────────
final devModeProvider = NotifierProvider<DevModeNotifier, bool>(DevModeNotifier.new);

class DevModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

// ── Selected Date ─────────────────────────────────────────
final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void select(DateTime d) => state = d;
}

// ── Habit List ────────────────────────────────────────────
final habitProvider =
    NotifierProvider<HabitNotifier, List<Habit>>(HabitNotifier.new);

class HabitNotifier extends Notifier<List<Habit>> {
  // ── Undo / Redo history ──
  final List<List<Habit>> _history = [];
  final List<List<Habit>> _future = [];

  bool get canUndo => _history.isNotEmpty;
  bool get canRedo => _future.isNotEmpty;

  @override
  List<Habit> build() => _seedHabits();

  void _pushHistory() {
    _history.add(state.map((h) => h.copyWith()).toList());
    _future.clear();
  }

  void undo() {
    if (!canUndo) return;
    _future.add(state.map((h) => h.copyWith()).toList());
    state = _history.removeLast();
  }

  void redo() {
    if (!canRedo) return;
    _history.add(state.map((h) => h.copyWith()).toList());
    state = _future.removeLast();
  }

  // ── CRUD ──
  void add(Habit habit) {
    _pushHistory();
    state = [...state, habit]..sort((a, b) => a.sortMinutes.compareTo(b.sortMinutes));
  }

  void edit(String id, {String? name, String? time, String? place, int? iconCodePoint}) {
    _pushHistory();
    state = [
      for (final h in state)
        if (h.id == id)
          h.copyWith(name: name, time: time, place: place, iconCodePoint: iconCodePoint)
        else
          h,
    ]..sort((a, b) => a.sortMinutes.compareTo(b.sortMinutes));
  }

  void delete(String id) {
    _pushHistory();
    state = state.where((h) => h.id != id).toList();
  }

  // ── Mark done / skip ──
  void markDone(String id, DateTime date) {
    _pushHistory();
    state = [
      for (final h in state)
        if (h.id == id)
          h.copyWith(
            completions: {...h.completions, Habit.dateKey(date): 'done'},
          )
        else
          h,
    ];
  }

  void markSkip(String id, DateTime date) {
    _pushHistory();
    state = [
      for (final h in state)
        if (h.id == id)
          h.copyWith(
            completions: {...h.completions, Habit.dateKey(date): 'skip'},
          )
        else
          h,
    ];
  }

  /// Reorder: move habit to the bottom of the list.
  void moveToBottom(String id) {
    final habit = state.firstWhere((h) => h.id == id);
    state = [...state.where((h) => h.id != id), habit];
  }

  // ── Seed data ──
  static List<Habit> _seedHabits() {
    return [
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
  }
}
