import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/habit_repository.dart';
import '../models/habit_model.dart';

// ── Dev Mode ──────────────────────────────────────────────
final devModeProvider = NotifierProvider<DevModeNotifier, bool>(
  DevModeNotifier.new,
);

class DevModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

// ── Selected Date ─────────────────────────────────────────
final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(
  SelectedDateNotifier.new,
);

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void select(DateTime d) => state = d;
}

// ── Habit List (Hive-persisted) ───────────────────────────
final habitProvider = NotifierProvider<HabitNotifier, List<Habit>>(
  HabitNotifier.new,
);

class HabitNotifier extends Notifier<List<Habit>> {
  // ── Undo / Redo history (in-memory, not persisted) ──
  final List<List<Habit>> _history = [];
  final List<List<Habit>> _future = [];

  bool get canUndo => _history.isNotEmpty;
  bool get canRedo => _future.isNotEmpty;

  HabitRepository get _repo => ref.read(habitRepositoryProvider);

  @override
  List<Habit> build() {
    // Load from Hive on startup
    return _repo.getAll();
  }

  void _pushHistory() {
    _history.add(state.map((h) => h.copyWith()).toList());
    _future.clear();
  }

  /// Persist current state list to Hive.
  Future<void> _persist() async {
    await _repo.clear();
    await _repo.putAll(state);
  }

  void undo() {
    if (!canUndo) return;
    _future.add(state.map((h) => h.copyWith()).toList());
    state = _history.removeLast();
    _persist();
  }

  void redo() {
    if (!canRedo) return;
    _history.add(state.map((h) => h.copyWith()).toList());
    state = _future.removeLast();
    _persist();
  }

  // ── CRUD ──
  void add(Habit habit) {
    _pushHistory();
    state = [...state, habit]
      ..sort((a, b) => a.sortMinutes.compareTo(b.sortMinutes));
    _persist();
  }

  void edit(
    String id, {
    String? name,
    String? time,
    String? place,
    int? iconCodePoint,
  }) {
    _pushHistory();
    state = [
      for (final h in state)
        if (h.id == id)
          h.copyWith(
            name: name,
            time: time,
            place: place,
            iconCodePoint: iconCodePoint,
          )
        else
          h,
    ]..sort((a, b) => a.sortMinutes.compareTo(b.sortMinutes));
    _persist();
  }

  void delete(String id) {
    _pushHistory();
    state = state.where((h) => h.id != id).toList();
    _persist();
  }

  void deleteMany(List<String> ids) {
    _pushHistory();
    final idSet = ids.toSet();
    state = state.where((h) => !idSet.contains(h.id)).toList();
    _persist();
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
    _persist();
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
    _persist();
  }

  /// Reorder: move habit to the bottom of the list.
  void moveToBottom(String id) {
    final habit = state.firstWhere((h) => h.id == id);
    state = [...state.where((h) => h.id != id), habit];
    _persist();
  }
}
