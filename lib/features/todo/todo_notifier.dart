import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'todo_model.dart';
import 'todo_repository.dart';

// ──── State ────

class TodoState {
  const TodoState({this.tasks = const [], this.selectedTag = 'All'});

  final List<TodoTask> tasks;
  final String selectedTag;

  /// Dynamic tags derived from pending tasks, plus 'All'.
  List<String> get dynamicTags {
    final tags =
        tasks
            .where((t) => t.status == TaskStatus.pending)
            .map((t) => t.tag)
            .toSet()
            .toList()
          ..sort();
    return ['All', ...tags];
  }

  List<TodoTask> get filteredTasks {
    if (selectedTag == 'All') {
      return tasks.where((t) => t.status == TaskStatus.pending).toList();
    }
    return tasks
        .where((t) => t.status == TaskStatus.pending && t.tag == selectedTag)
        .toList();
  }

  TodoState copyWith({List<TodoTask>? tasks, String? selectedTag}) {
    return TodoState(
      tasks: tasks ?? this.tasks,
      selectedTag: selectedTag ?? this.selectedTag,
    );
  }
}

// ──── Notifier (Hive-persisted) ────

class TodoNotifier extends Notifier<TodoState> {
  final List<List<TodoTask>> _undoStack = [];
  final List<List<TodoTask>> _redoStack = [];

  TodoRepository get _repo => ref.read(todoRepositoryProvider);

  @override
  TodoState build() {
    // Load from Hive on startup
    return TodoState(tasks: _repo.getAll());
  }

  // ── Snapshot helpers ──

  void _pushUndo() {
    _undoStack.add(List.of(state.tasks));
    _redoStack.clear();
  }

  /// Persist current task list to Hive.
  Future<void> _persist() async {
    await _repo.clear();
    await _repo.putAll(state.tasks);
  }

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void undo() {
    if (!canUndo) return;
    _redoStack.add(List.of(state.tasks));
    state = state.copyWith(tasks: _undoStack.removeLast());
    _persist();
  }

  void redo() {
    if (!canRedo) return;
    _undoStack.add(List.of(state.tasks));
    state = state.copyWith(tasks: _redoStack.removeLast());
    _persist();
  }

  // ── Tag Filter ──

  void selectTag(String tag) {
    if (tag != 'All' && !state.dynamicTags.contains(tag)) {
      state = state.copyWith(selectedTag: 'All');
    } else {
      state = state.copyWith(selectedTag: tag);
    }
  }

  // ── CRUD ──

  void addTask(TodoTask task) {
    _pushUndo();
    state = state.copyWith(tasks: [...state.tasks, task]);
    _persist();
  }

  void editTask(TodoTask updated) {
    _pushUndo();
    state = state.copyWith(
      tasks: state.tasks.map((t) => t.id == updated.id ? updated : t).toList(),
    );
    _persist();
  }

  void deleteTask(String id) {
    _pushUndo();
    final newTasks = state.tasks.where((t) => t.id != id).toList();
    final newState = state.copyWith(tasks: newTasks);
    if (!newState.dynamicTags.contains(state.selectedTag)) {
      state = newState.copyWith(selectedTag: 'All');
    } else {
      state = newState;
    }
    _persist();
  }

  void deleteTasks(List<String> ids) {
    _pushUndo();
    final idSet = ids.toSet();
    final newTasks = state.tasks.where((t) => !idSet.contains(t.id)).toList();
    final newState = state.copyWith(tasks: newTasks);
    if (!newState.dynamicTags.contains(state.selectedTag)) {
      state = newState.copyWith(selectedTag: 'All');
    } else {
      state = newState;
    }
    _persist();
  }

  // ── Swipe Actions ──

  void markDone(String id) {
    _pushUndo();
    state = state.copyWith(
      tasks: state.tasks
          .map((t) => t.id == id ? t.copyWith(status: TaskStatus.done) : t)
          .toList(),
    );
    _persist();
  }

  void markSkipped(String id) {
    _pushUndo();
    state = state.copyWith(
      tasks: state.tasks
          .map((t) => t.id == id ? t.copyWith(status: TaskStatus.skipped) : t)
          .toList(),
    );
    _persist();
  }
}

// ──── Provider ────

final todoNotifierProvider = NotifierProvider<TodoNotifier, TodoState>(
  TodoNotifier.new,
);
