import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../habits/habits_screen.dart';
import '../habits/providers/habit_provider.dart';
import '../journal/journal_screen.dart';
import '../profile/profile_screen.dart';
import '../todo/todo_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  static const _titles = ['Habit Tracker', 'To Do List', 'Journal', 'Profile'];

  static const _screens = <Widget>[
    HabitsScreen(),
    TodoScreen(),
    JournalScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final devMode = ref.watch(devModeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
