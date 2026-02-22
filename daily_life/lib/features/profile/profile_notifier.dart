import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../habits/providers/habit_provider.dart';
import '../journal/state/journal_notifier.dart';
import '../todo/todo_model.dart';
import '../todo/todo_notifier.dart';

// ═══════════════════════════════════════════════════════════
//  Profile State
// ═══════════════════════════════════════════════════════════

class ProfileState {
  const ProfileState({
    this.fullName = 'User',
    this.email = '',
    this.memberSince = '',
    this.dailyReminders = true,
    this.achievementAlerts = true,
    this.themeMode = ThemeMode.dark,
  });

  final String fullName;
  final String email;
  final String memberSince;
  final bool dailyReminders;
  final bool achievementAlerts;
  final ThemeMode themeMode;

  ProfileState copyWith({
    String? fullName,
    String? email,
    String? memberSince,
    bool? dailyReminders,
    bool? achievementAlerts,
    ThemeMode? themeMode,
  }) {
    return ProfileState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      memberSince: memberSince ?? this.memberSince,
      dailyReminders: dailyReminders ?? this.dailyReminders,
      achievementAlerts: achievementAlerts ?? this.achievementAlerts,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  /// Serialize to a simple map for Hive storage.
  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'email': email,
    'memberSince': memberSince,
    'dailyReminders': dailyReminders,
    'achievementAlerts': achievementAlerts,
    'themeMode': themeMode.index,
  };

  /// Deserialize from Hive map.
  factory ProfileState.fromMap(Map<dynamic, dynamic> m) {
    return ProfileState(
      fullName: m['fullName'] as String? ?? 'User',
      email: m['email'] as String? ?? '',
      memberSince: m['memberSince'] as String? ?? '',
      dailyReminders: m['dailyReminders'] as bool? ?? true,
      achievementAlerts: m['achievementAlerts'] as bool? ?? true,
      themeMode: ThemeMode.values[m['themeMode'] as int? ?? 2],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Profile Notifier (Hive-persisted)
// ═══════════════════════════════════════════════════════════

/// Hive box provider for profile settings.
final profileBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError('profileBoxProvider must be overridden at startup');
});

class ProfileNotifier extends Notifier<ProfileState> {
  Box get _box => ref.read(profileBoxProvider);

  @override
  ProfileState build() {
    final raw = _box.get('profile');
    if (raw != null && raw is Map) {
      return ProfileState.fromMap(raw);
    }
    // First launch – set memberSince to current year
    final initial = ProfileState(memberSince: DateTime.now().year.toString());
    _box.put('profile', initial.toMap());
    return initial;
  }

  void _save() {
    _box.put('profile', state.toMap());
  }

  void updateName(String name) {
    state = state.copyWith(fullName: name);
    _save();
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
    _save();
  }

  void toggleDailyReminders() {
    state = state.copyWith(dailyReminders: !state.dailyReminders);
    _save();
  }

  void toggleAchievementAlerts() {
    state = state.copyWith(achievementAlerts: !state.achievementAlerts);
    _save();
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _save();
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);

// ═══════════════════════════════════════════════════════════
//  Computed Stats (read-only providers)
// ═══════════════════════════════════════════════════════════

/// Current consecutive days the user completed all habits.
final habitStreakProvider = Provider<int>((ref) {
  final habits = ref.watch(habitProvider);
  if (habits.isEmpty) return 0;

  int streak = 0;
  final now = DateTime.now();

  for (int d = 0; d < 365; d++) {
    final date = now.subtract(Duration(days: d));
    final allDone = habits.every((h) => h.isCompleted(date));
    if (allDone) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
});

/// Percentage of tasks marked done out of total tasks.
final tasksDonePercentProvider = Provider<int>((ref) {
  final todoState = ref.watch(todoNotifierProvider);
  final total = todoState.tasks.length;
  if (total == 0) return 0;
  final done = todoState.tasks.where((t) => t.status == TaskStatus.done).length;
  return ((done / total) * 100).round();
});

/// Total journal entries count.
final journalEntryCountProvider = Provider<int>((ref) {
  final journalState = ref.watch(journalNotifierProvider);
  return journalState.entries.length;
});
