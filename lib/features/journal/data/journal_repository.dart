import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'journal_entry.dart';

class JournalRepository {
  JournalRepository(this._box);

  final Box<JournalEntry> _box;

  List<JournalEntry> getAll() {
    final entries = _box.values.toList();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  Future<void> add(JournalEntry entry) async {
    await _box.put(entry.id, entry);
  }

  Future<void> update(JournalEntry entry) async {
    await _box.put(entry.id, entry);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  JournalEntry? getById(String id) {
    return _box.get(id);
  }
}

final journalBoxProvider = Provider<Box<JournalEntry>>((ref) {
  throw UnimplementedError('journalBoxProvider must be overridden at startup');
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final box = ref.watch(journalBoxProvider);
  return JournalRepository(box);
});
