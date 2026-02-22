import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/habits/data/habit_adapter.dart';
import 'features/habits/data/habit_repository.dart';
import 'features/habits/models/habit_model.dart';
import 'features/journal/data/journal_entry.dart';
import 'features/journal/data/journal_entry.g.dart';
import 'features/journal/data/journal_repository.dart';
import 'features/profile/profile_notifier.dart';
import 'features/shell/app_shell.dart';
import 'features/todo/todo_adapter.dart';
import 'features/todo/todo_model.dart';
import 'features/todo/todo_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // ── Initialize Hive ──
  await Hive.initFlutter();

  // Register all adapters
  Hive.registerAdapter(JournalEntryAdapter()); // typeId 1
  Hive.registerAdapter(HabitAdapter()); // typeId 2
  Hive.registerAdapter(TodoTaskAdapter()); // typeId 3

  // Open all boxes
  final journalBox = await Hive.openBox<JournalEntry>('journal_entries');
  final habitBox = await Hive.openBox<Habit>('habits');
  final todoBox = await Hive.openBox<TodoTask>('tasks');
  final profileBox = await Hive.openBox('profile_settings');

  // Seed default data on first launch
  final habitRepo = HabitRepository(habitBox);
  await habitRepo.seedIfEmpty();

  final todoRepo = TodoRepository(todoBox);
  await todoRepo.seedIfEmpty();

  // ── Lock orientation for consistent UI ──
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      overrides: [
        journalBoxProvider.overrideWithValue(journalBox),
        habitBoxProvider.overrideWithValue(habitBox),
        todoBoxProvider.overrideWithValue(todoBox),
        profileBoxProvider.overrideWithValue(profileBox),
      ],
      child: const DailyLifeApp(),
    ),
  );
}

class DailyLifeApp extends StatelessWidget {
  const DailyLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailyLife',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppShell(),
    );
  }
}
