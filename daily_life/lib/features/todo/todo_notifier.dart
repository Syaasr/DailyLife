import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'todo_model.dart';

// ──── State ────

class TodoState {
  const TodoState({
    this.tasks = const [],
    this.selectedTag = 'All',
    this.devMode = false,
  });

  final List<TodoTask> tasks;
  final String selectedTag;
  final bool devMode;

  List<TodoTask> get filteredTasks {
    if (selectedTag == 'All') {
      return tasks.where((t) => t.status == TaskStatus.pending).toList();
    }
    return tasks
        .where((t) => t.status == TaskStatus.pending && t.tag == selectedTag)
        .toList();
  }

  TodoState copyWith({
    List<TodoTask>? tasks,
    String? selectedTag,
    bool? devMode,
  }) {
    return TodoState(
      tasks: tasks ?? this.tasks,
      selectedTag: selectedTag ?? this.selectedTag,
      devMode: devMode ?? this.devMode,
    );
  }
}

// ──── Notifier ────

class TodoNotifier extends Notifier<TodoState> {
  final List<List<TodoTask>> _undoStack = [];
  final List<List<TodoTask>> _redoStack = [];

  @override
  TodoState build() {
    return TodoState(tasks: _sampleTasks());
  }

  // ── Snapshot helpers ──

  void _pushUndo() {
    _undoStack.add(List.of(state.tasks));
    _redoStack.clear();
  }

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void undo() {
    if (!canUndo) return;
    _redoStack.add(List.of(state.tasks));
    state = state.copyWith(tasks: _undoStack.removeLast());
  }

  void redo() {
    if (!canRedo) return;
    _undoStack.add(List.of(state.tasks));
    state = state.copyWith(tasks: _redoStack.removeLast());
  }

  // ── Dev mode ──

  void toggleDevMode() {
    state = state.copyWith(devMode: !state.devMode);
  }

  // ── Tag Filter ──

  void selectTag(String tag) {
    state = state.copyWith(selectedTag: tag);
  }

  // ── CRUD ──

  void addTask(TodoTask task) {
    _pushUndo();
    state = state.copyWith(tasks: [...state.tasks, task]);
  }

  void editTask(TodoTask updated) {
    _pushUndo();
    state = state.copyWith(
      tasks: state.tasks
          .map((t) => t.id == updated.id ? updated : t)
          .toList(),
    );
  }

  void deleteTask(String id) {
    _pushUndo();
    state = state.copyWith(
      tasks: state.tasks.where((t) => t.id != id).toList(),
    );
  }

  // ── Swipe Actions ──

  void markDone(String id) {
    _pushUndo();
    state = state.copyWith(
      tasks: state.tasks
          .map((t) => t.id == id ? t.copyWith(status: TaskStatus.done) : t)
          .toList(),
    );
  }

  void markSkipped(String id) {
    _pushUndo();
    state = state.copyWith(
      tasks: state.tasks
          .map((t) => t.id == id ? t.copyWith(status: TaskStatus.skipped) : t)
          .toList(),
    );
  }

  // ── Sample Data ──

  static List<TodoTask> _sampleTasks() {
    final now = DateTime.now();
    return [
      TodoTask(
        id: '1',
        name: 'Project Presentation',
        description:
            'Prepare the Q1 presentation slides for the team meeting. Include revenue charts and roadmap updates.',
        deadline: now.add(const Duration(hours: 3)),
        priority: TaskPriority.high,
        tag: 'Work',
      ),
      TodoTask(
        id: '2',
        name: 'Grocery Shopping',
        description:
            'Buy vegetables, fruits, milk, eggs, and bread from the supermarket.',
        deadline: now.add(const Duration(days: 1)),
        priority: TaskPriority.medium,
        tag: 'Personal',
      ),
      TodoTask(
        id: '3',
        name: 'Gym Session',
        description:
            'Upper body workout: bench press, overhead press, rows, and bicep curls.',
        deadline: now.add(const Duration(hours: 5)),
        priority: TaskPriority.low,
        tag: 'Health',
      ),
      TodoTask(
        id: '4',
        name: 'Code Review',
        description:
            'Review pull requests #42 and #45 on the backend repository. Check for security issues.',
        deadline: now.add(const Duration(hours: 1, minutes: 30)),
        priority: TaskPriority.high,
        tag: 'Work',
      ),
      TodoTask(
        id: '5',
        name: 'Read Book',
        description:
            'Continue reading "Atomic Habits" — finish Chapter 8 and take notes.',
        deadline: now.add(const Duration(days: 3)),
        priority: TaskPriority.low,
        tag: 'Personal',
      ),
      TodoTask(
        id: '6',
        name: 'Doctor Appointment',
        description:
            'Annual health check-up at City Hospital. Bring insurance card.',
        deadline: now.add(const Duration(days: 2)),
        priority: TaskPriority.medium,
        tag: 'Health',
      ),
    ];
  }
}

// ──── Provider ────

final todoNotifierProvider =
    NotifierProvider<TodoNotifier, TodoState>(TodoNotifier.new);
