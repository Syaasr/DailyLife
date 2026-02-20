import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_scaffold.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Month & Year
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'February 2026',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),

            // Date row
            const _DateRow(),
            const SizedBox(height: 24),

            // Habit cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Today's Goals",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),

            _HabitCard(
              name: 'Morning Yoga',
              time: '07:00 AM',
              place: 'Living Room',
              icon: Icons.self_improvement_rounded,
            ),
            _HabitCard(
              name: 'Read 10 Pages',
              time: '08:30 PM',
              place: 'Library',
              icon: Icons.menu_book_rounded,
            ),
            _HabitCard(
              name: 'Hydration Goal',
              time: 'All Day',
              place: 'Everywhere',
              icon: Icons.water_drop_rounded,
            ),
            const SizedBox(height: 24),

            // Weekly Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Weekly Progress',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            const _WeeklyChart(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ---------- Date Row ----------

class _DateRow extends StatelessWidget {
  const _DateRow();

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.add(Duration(days: i - 3)));

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final d = days[index];
          final isToday = d.day == today.day;
          return _DateChip(day: d, isSelected: isToday);
        },
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.day, this.isSelected = false});
  final DateTime day;
  final bool isSelected;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.glowingBlue
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.glowingBlue
              : AppColors.glassBorder.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _weekdays[day.weekday - 1],
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${day.day}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Habit Card ----------

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.name,
    required this.time,
    required this.place,
    required this.icon,
  });

  final String name;
  final String time;
  final String place;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(name),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 32),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Icon(Icons.check_circle, color: AppColors.success, size: 32),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 32),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Icon(Icons.skip_next_rounded, color: AppColors.warning, size: 32),
      ),
      onDismissed: (_) {},
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.glowingBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.glowingBlue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('$time  •  $place', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ---------- Weekly Chart Placeholder ----------

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart();

  @override
  Widget build(BuildContext context) {
    // Simple visual bar chart placeholder
    final data = [0.6, 0.8, 0.5, 0.9, 0.7, 1.0, 0.4];
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 80 * data[i],
                decoration: BoxDecoration(
                  color: AppColors.glowingBlue.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 6),
              Text(labels[i], style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          );
        }),
      ),
    );
  }
}
