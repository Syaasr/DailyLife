import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_scaffold.dart';
import 'models/habit_model.dart';
import 'providers/habit_provider.dart';

// ═══════════════════════════════════════════════════════════
//  Habits Screen
// ═══════════════════════════════════════════════════════════

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devMode = ref.watch(devModeProvider);

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        actions: [
          IconButton(
            icon: Icon(
              devMode ? Icons.settings_rounded : Icons.settings_outlined,
              color: devMode ? AppColors.glowingBlue : AppColors.textPrimary,
            ),
            onPressed: () =>
                ref.read(devModeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Month & Year
            const _MonthYearLabel(),
            const SizedBox(height: 12),

            // Scrollable Date Row
            const _ScrollableDateRow(),
            const SizedBox(height: 20),

            // Dev mode toolbar
            if (devMode) const _DevModeToolbar(),
            if (devMode) const SizedBox(height: 12),

            // Section title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Today's Goals",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),

            // Habit Card Stack
            const _HabitCardStack(),
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
            const _WeeklyLineChart(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Month & Year Label
// ═══════════════════════════════════════════════════════════

class _MonthYearLabel extends ConsumerWidget {
  const _MonthYearLabel();

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDateProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        '${_months[selected.month - 1]} ${selected.year}',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Scrollable Date Row  (today ±2, swipeable)
// ═══════════════════════════════════════════════════════════

class _ScrollableDateRow extends ConsumerStatefulWidget {
  const _ScrollableDateRow();

  @override
  ConsumerState<_ScrollableDateRow> createState() => _ScrollableDateRowState();
}

class _ScrollableDateRowState extends ConsumerState<_ScrollableDateRow> {
  late final PageController _pageCtrl;
  static const int _totalPages = 365; // ±half year
  static const int _centerPage = 182;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(
      initialPage: _centerPage,
      viewportFraction: 1,
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final today = DateTime.now();

    return SizedBox(
      height: 84,
      child: PageView.builder(
        controller: _pageCtrl,
        itemCount: _totalPages,
        onPageChanged: (page) {
          final offset = page - _centerPage;
          final centerDate = today.add(Duration(days: offset));
          ref.read(selectedDateProvider.notifier).select(centerDate);
        },
        itemBuilder: (context, page) {
          final offset = page - _centerPage;
          final centerDate = today.add(Duration(days: offset));
          final days = List.generate(
              5, (i) => centerDate.add(Duration(days: i - 2)));

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: days.map((d) {
              final isSelected = d.year == selectedDate.year &&
                  d.month == selectedDate.month &&
                  d.day == selectedDate.day;
              final isToday = d.year == today.year &&
                  d.month == today.month &&
                  d.day == today.day;
              return GestureDetector(
                onTap: () {
                  ref.read(selectedDateProvider.notifier).select(d);
                },
                child: _DateChip(day: d, isSelected: isSelected, isToday: isToday),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.day,
    this.isSelected = false,
    this.isToday = false,
  });
  final DateTime day;
  final bool isSelected;
  final bool isToday;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.glowingBlue
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isToday && !isSelected
              ? AppColors.glowingBlue.withValues(alpha: 0.6)
              : isSelected
                  ? AppColors.glowingBlue
                  : AppColors.glassBorder.withValues(alpha: 0.2),
          width: isToday && !isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.glowingBlue.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
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

// ═══════════════════════════════════════════════════════════
//  Dev Mode Toolbar
// ═══════════════════════════════════════════════════════════

class _DevModeToolbar extends ConsumerWidget {
  const _DevModeToolbar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(habitProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.glassBorder.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ToolbarBtn(
                  icon: Icons.undo_rounded,
                  label: 'Undo',
                  onTap: () => notifier.undo(),
                ),
                _ToolbarBtn(
                  icon: Icons.redo_rounded,
                  label: 'Redo',
                  onTap: () => notifier.redo(),
                ),
                _ToolbarBtn(
                  icon: Icons.add_rounded,
                  label: 'Add',
                  onTap: () => _showAddDialog(context, ref),
                ),
                _ToolbarBtn(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  onTap: () => _showEditDialog(context, ref),
                ),
                _ToolbarBtn(
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                  onTap: () => _showDeleteDialog(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '08:00');
    final placeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepSapphire,
        title: const Text('Add Habit', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(nameCtrl, 'Name'),
            const SizedBox(height: 8),
            _dialogField(timeCtrl, 'Time (HH:mm)'),
            const SizedBox(height: 8),
            _dialogField(placeCtrl, 'Place'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              ref.read(habitProvider.notifier).add(
                    Habit(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameCtrl.text.trim(),
                      time: timeCtrl.text.trim(),
                      place: placeCtrl.text.trim(),
                      iconCodePoint: Icons.star_rounded.codePoint,
                    ),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final habits = ref.read(habitProvider);
    if (habits.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepSapphire,
        title:
            const Text('Edit Habit', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: habits.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(habits[i].name,
                  style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _showEditFieldDialog(context, ref, habits[i]);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showEditFieldDialog(BuildContext context, WidgetRef ref, Habit habit) {
    final nameCtrl = TextEditingController(text: habit.name);
    final timeCtrl = TextEditingController(text: habit.time);
    final placeCtrl = TextEditingController(text: habit.place);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepSapphire,
        title: Text('Edit "${habit.name}"',
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(nameCtrl, 'Name'),
            const SizedBox(height: 8),
            _dialogField(timeCtrl, 'Time (HH:mm)'),
            const SizedBox(height: 8),
            _dialogField(placeCtrl, 'Place'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(habitProvider.notifier).edit(
                    habit.id,
                    name: nameCtrl.text.trim(),
                    time: timeCtrl.text.trim(),
                    place: placeCtrl.text.trim(),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final habits = ref.read(habitProvider);
    if (habits.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepSapphire,
        title: const Text('Delete Habit',
            style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: habits.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(habits[i].name,
                  style: const TextStyle(color: Colors.white)),
              trailing:
                  const Icon(Icons.delete_outline, color: AppColors.error),
              onTap: () {
                ref.read(habitProvider.notifier).delete(habits[i].id);
                Navigator.pop(ctx);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: AppColors.glassBorder.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.glowingBlue),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  const _ToolbarBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.glowingBlue, size: 20),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(fontSize: 9, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Habit Card Stack  (swipe left=done, right=skip)
// ═══════════════════════════════════════════════════════════

class _HabitCardStack extends ConsumerWidget {
  const _HabitCardStack();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    if (habits.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No habits yet.\nEnable dev mode to add habits.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Column(
      children: habits.map((habit) {
        final done = habit.isDone(selectedDate);
        final skipped = habit.isSkipped(selectedDate);

        return Dismissible(
          key: ValueKey('${habit.id}_${Habit.dateKey(selectedDate)}'),
          direction: (done || skipped)
              ? DismissDirection.none
              : DismissDirection.horizontal,
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Swipe right → skip
              ref.read(habitProvider.notifier).markSkip(habit.id, selectedDate);
              ref.read(habitProvider.notifier).moveToBottom(habit.id);
            } else {
              // Swipe left → done
              ref.read(habitProvider.notifier).markDone(habit.id, selectedDate);
              ref.read(habitProvider.notifier).moveToBottom(habit.id);
            }
            return false; // don't remove from tree
          },
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 32),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Row(
              children: [
                Icon(Icons.skip_next_rounded, color: AppColors.warning, size: 32),
                SizedBox(width: 8),
                Text('Skip', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 32),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Done', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                SizedBox(width: 8),
                Icon(Icons.check_circle, color: AppColors.success, size: 32),
              ],
            ),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: (done || skipped) ? 0.5 : 1.0,
            child: GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: done
                          ? AppColors.success.withValues(alpha: 0.2)
                          : skipped
                              ? AppColors.warning.withValues(alpha: 0.2)
                              : AppColors.glowingBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      done
                          ? Icons.check_circle
                          : skipped
                              ? Icons.skip_next_rounded
                              : habit.icon,
                      color: done
                          ? AppColors.success
                          : skipped
                              ? AppColors.warning
                              : AppColors.glowingBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            decoration: done
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${habit.time}  •  ${habit.place}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (done)
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 20)
                  else if (skipped)
                    const Icon(Icons.skip_next_rounded,
                        color: AppColors.warning, size: 20)
                  else
                    const Icon(Icons.chevron_right,
                        color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Weekly Line Chart
// ═══════════════════════════════════════════════════════════

class _WeeklyLineChart extends ConsumerWidget {
  const _WeeklyLineChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    // Compute the Monday of the selected week
    final weekday = selectedDate.weekday; // 1=Mon
    final monday = selectedDate.subtract(Duration(days: weekday - 1));

    final spots = <FlSpot>[];
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final key = Habit.dateKey(day);
      if (habits.isEmpty) {
        spots.add(FlSpot(i.toDouble(), 0));
        continue;
      }
      final completed =
          habits.where((h) => h.completions[key] == 'done').length;
      final pct = (completed / habits.length) * 100;
      spots.add(FlSpot(i.toDouble(), pct));
    }

    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 100,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (_) => FlLine(
                color: AppColors.glassBorder.withValues(alpha: 0.15),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  interval: 25,
                  getTitlesWidget: (v, _) => Text(
                    '${v.toInt()}%',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (v, _) {
                    final idx = v.toInt();
                    if (idx < 0 || idx > 6) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        labels[idx],
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textMuted),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.3,
                color: AppColors.glowingBlue,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, xPercentage, bar, index) => FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.glowingBlue,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.glowingBlue.withValues(alpha: 0.3),
                      AppColors.glowingBlue.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) => spots
                    .map((s) => LineTooltipItem(
                          '${s.y.toInt()}%',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
