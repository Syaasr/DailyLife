import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/journal/data/journal_entry.dart';
import 'features/journal/data/journal_entry.g.dart';
import 'features/journal/data/journal_repository.dart';
import 'features/shell/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(JournalEntryAdapter());
  final journalBox = await Hive.openBox<JournalEntry>('journal_entries');

  runApp(
    ProviderScope(
      overrides: [
        journalBoxProvider.overrideWithValue(journalBox),
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
