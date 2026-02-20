import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/journal_entry.dart';
import '../data/journal_repository.dart';

class JournalState {
  const JournalState({
    this.entries = const [],
    this.selectedTag = 'All',
    this.searchQuery = '',
    this.devMode = false,
    this.tags = const ['All', 'Gratitude', 'Ideas', 'Reflection', 'Personal', 'Work'],
  });

  final List<JournalEntry> entries;
  final String selectedTag;
  final String searchQuery;
  final bool devMode;
  final List<String> tags;

  List<JournalEntry> get filteredEntries {
    return entries.where((e) {
      final matchesTag = selectedTag == 'All' || e.tag == selectedTag;
      final matchesSearch = searchQuery.isEmpty ||
          e.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          e.content.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesTag && matchesSearch;
    }).toList();
  }

  JournalState copyWith({
    List<JournalEntry>? entries,
    String? selectedTag,
    String? searchQuery,
    bool? devMode,
    List<String>? tags,
  }) {
    return JournalState(
      entries: entries ?? this.entries,
      selectedTag: selectedTag ?? this.selectedTag,
      searchQuery: searchQuery ?? this.searchQuery,
      devMode: devMode ?? this.devMode,
      tags: tags ?? this.tags,
    );
  }
}

class JournalNotifier extends Notifier<JournalState> {
  static const _uuid = Uuid();

  // Undo/Redo stacks store snapshots of the entries list
  final List<List<JournalEntry>> _undoStack = [];
  final List<List<JournalEntry>> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  JournalRepository get _repository => ref.read(journalRepositoryProvider);

  @override
  JournalState build() {
    final entries = _repository.getAll();
    return JournalState(entries: entries);
  }

  void _pushUndo() {
    _undoStack.add(List.of(state.entries));
    _redoStack.clear();
  }

  Future<void> addEntry({
    required String title,
    required String content,
    required String tag,
  }) async {
    _pushUndo();
    final now = DateTime.now();
    final entry = JournalEntry(
      id: _uuid.v4(),
      title: title,
      content: content,
      tag: tag,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.add(entry);
    _reload();
  }

  Future<void> updateEntry(JournalEntry updated) async {
    _pushUndo();
    final entry = updated.copyWith(updatedAt: DateTime.now());
    await _repository.update(entry);
    _reload();
  }

  Future<void> deleteEntry(String id) async {
    _pushUndo();
    await _repository.delete(id);
    _reload();
  }

  Future<void> undo() async {
    if (_undoStack.isEmpty) return;
    _redoStack.add(List.of(state.entries));
    final previous = _undoStack.removeLast();

    // Rebuild Hive box from the snapshot
    for (final entry in state.entries) {
      await _repository.delete(entry.id);
    }
    for (final entry in previous) {
      await _repository.add(entry);
    }
    state = state.copyWith(entries: previous);
  }

  Future<void> redo() async {
    if (_redoStack.isEmpty) return;
    _undoStack.add(List.of(state.entries));
    final next = _redoStack.removeLast();

    for (final entry in state.entries) {
      await _repository.delete(entry.id);
    }
    for (final entry in next) {
      await _repository.add(entry);
    }
    state = state.copyWith(entries: next);
  }

  void setTag(String tag) {
    state = state.copyWith(selectedTag: tag);
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleDevMode() {
    state = state.copyWith(devMode: !state.devMode);
  }

  void _reload() {
    final entries = _repository.getAll();
    state = state.copyWith(entries: entries);
  }
}

final journalNotifierProvider =
    NotifierProvider<JournalNotifier, JournalState>(JournalNotifier.new);
