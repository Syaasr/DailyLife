import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/edit_mode_toolbar.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/tutorial_dialog.dart';
import 'models/habit_model.dart';
import 'providers/habit_provider.dart';

// ═══════════════════════════════════════════════════════════
//  Habits Screen
// ═══════════════════════════════════════════════════════════

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  final Set<String> _selectedIds = {};

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _deleteSelected() {
    ref.read(habitProvider.notifier).deleteMany(_selectedIds.toList());
    setState(() => _selectedIds.clear());
  }

  @override
  Widget build(BuildContext context) {
    final devMode = ref.watch(devModeProvider);

    // Clear selections when edit mode is turned off
    if (!devMode && _selectedIds.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedIds.clear());
      });
    }

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).select(DateTime.now());
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.textPrimary),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const TutorialDialog(),
              );
            },
          ),
          if (devMode)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                'Edit Mode',
                style: TextStyle(
                  color: AppColors.glowingBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Month & Year + Calendar button
            _MonthYearLabel(),
            const SizedBox(height: 12),

            // Pill-shaped Horizontal Date Picker
            const _PillDatePicker(),
            const SizedBox(height: 20),

            // Edit mode toolbar (shared widget)
            _buildEditToolbar(context, devMode),

            // Card stack
            _HabitCardStack(
              selectedIds: _selectedIds,
              onToggleSelect: _toggleSelect,
            ),
            const SizedBox(height: 20),

            // Chart — syncs with selected date
            const _WeeklyChart(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildEditToolbar(BuildContext context, bool devMode) {
    final notifier = ref.read(habitProvider.notifier);
    return EditModeToolbar(
      visible: devMode,
      actions: [
        EditModeAction(
          icon: Icons.undo,
          label: 'Undo',
          enabled: notifier.canUndo,
          onTap: notifier.undo,
        ),
        EditModeAction(
          icon: Icons.redo,
          label: 'Redo',
          enabled: notifier.canRedo,
          onTap: notifier.redo,
        ),
        EditModeAction(
          icon: Icons.add_circle_outline,
          label: 'Add',
          onTap: () => _showAddDialog(context, ref),
        ),
        EditModeAction(
          icon: Icons.edit_outlined,
          label: 'Edit',
          onTap: () => _showEditDialog(context, ref),
        ),
        if (_selectedIds.isNotEmpty)
          EditModeAction(
            icon: Icons.delete_outline,
            label: 'Del (${_selectedIds.length})',
            onTap: _deleteSelected,
          )
        else
          EditModeAction(
            icon: Icons.delete_outline,
            label: 'Delete',
            onTap: () => _showDeleteDialog(context, ref),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Month & Year Label with Calendar button
// ═══════════════════════════════════════════════════════════

class _MonthYearLabel extends ConsumerWidget {
  static const _months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDateProvider);
    return Row(
      children: [
        Text(
          '${_months[selected.month]} ${selected.year}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        // Calendar button for distant dates
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selected,
              firstDate: DateTime(2020),
              lastDate: DateTime(2050),
              builder: (ctx, child) {
                return Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.glowingBlue,
                      surface: AppColors.deepSapphireDark,
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              ref.read(selectedDateProvider.notifier).select(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.glassBorder.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.glowingBlue,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Pill-Shaped Horizontal Date Picker
//  — free scroll + snap-to-center + haptic feedback
// ═══════════════════════════════════════════════════════════

class _PillDatePicker extends ConsumerStatefulWidget {
  const _PillDatePicker();

  @override
  ConsumerState<_PillDatePicker> createState() => _PillDatePickerState();
}

class _PillDatePickerState extends ConsumerState<_PillDatePicker> {
  static const double itemExtent = 60.0;   // width + spacing
  static const double itemDiameter = 52.0; // the visible circle
  static const int _pastDays = 30;
  static const int _futureDays = 30;
  static const int _totalDays = _pastDays + 1 + _futureDays; // 61

  late final ScrollController _sc;
  late final List<DateTime> _dates;
  double _vpWidth = 0;          // viewport width from LayoutBuilder
  int _activeIndex = _pastDays; // index currently snapped to center
  bool _didInitScroll = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dates = List.generate(_totalDays, (i) {
      return DateTime(now.year, now.month, now.day)
          .add(Duration(days: i - _pastDays));
    });
    _sc = ScrollController();
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  // ── Centering math ──────────────────────────────────────
  // Each item occupies [itemExtent] px.
  // We add (vpWidth/2 − itemExtent/2) padding on both sides
  // so item 0 can reach the center.
  // Scroll offset to center item[i]:
  //   i * itemExtent
  double _offsetForIndex(int i) => i * itemExtent;

  void _animateToIndex(int i) {
    if (!_sc.hasClients) return;
    _sc.animateTo(
      _offsetForIndex(i).clamp(0.0, _sc.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _jumpToIndex(int i) {
    if (!_sc.hasClients) return;
    _sc.jumpTo(
      _offsetForIndex(i).clamp(0.0, _sc.position.maxScrollExtent),
    );
  }

  // ── Which index is currently nearest center? ────────────
  int _indexFromScroll() {
    if (!_sc.hasClients) return _pastDays;
    return (_sc.offset / itemExtent).round().clamp(0, _totalDays - 1);
  }

  // ── Called after user finishes scrolling ─────────────────
  void _onScrollEnd() {
    final i = _indexFromScroll();
    _animateToIndex(i);
    if (i != _activeIndex) {
      setState(() => _activeIndex = i);
      ref.read(selectedDateProvider.notifier).select(_dates[i]);
      HapticFeedback.lightImpact();
    }
  }

  // ── Called on tap ────────────────────────────────────────
  void _onTapIndex(int i) {
    setState(() => _activeIndex = i);
    ref.read(selectedDateProvider.notifier).select(_dates[i]);
    _animateToIndex(i);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    // Also react to external date changes (e.g. calendar picker)
    final selectedDate = ref.watch(selectedDateProvider);
    final providerIndex = _indexOfDate(selectedDate);
    if (providerIndex != _activeIndex && _didInitScroll) {
      _activeIndex = providerIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateToIndex(providerIndex);
      });
    }

    return LayoutBuilder(builder: (_, box) {
      _vpWidth = box.maxWidth;
      final halfPad = (_vpWidth / 2) - (itemExtent / 2);

      // Initial scroll to today on first layout
      if (!_didInitScroll) {
        _didInitScroll = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _jumpToIndex(_activeIndex);
        });
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollEndNotification) _onScrollEnd();
                return false;
              },
              child: ListView.builder(
                controller: _sc,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _totalDays,
                padding: EdgeInsets.symmetric(horizontal: halfPad),
                itemBuilder: (_, i) {
                  return _PillDateItem(
                    date: _dates[i],
                    isActive: i == _activeIndex,
                    onTap: () => _onTapIndex(i),
                  );
                },
              ),
            ),
          ),
        ),
      );
    });
  }

  int _indexOfDate(DateTime d) {
    for (int i = 0; i < _dates.length; i++) {
      if (_dates[i].year == d.year &&
          _dates[i].month == d.month &&
          _dates[i].day == d.day) {
        return i;
      }
    }
    return _pastDays;
  }
}

// ═══════════════════════════════════════════════════════════
//  Single date circle inside the pill
// ═══════════════════════════════════════════════════════════

class _PillDateItem extends StatelessWidget {
  const _PillDateItem({
    required this.date,
    required this.isActive,
    required this.onTap,
  });

  final DateTime date;
  final bool isActive;
  final VoidCallback onTap;

  static const _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const _blue = Color(0xFF3B82F6);
  static const _dark = Color(0xFF0A0A1A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: _PillDatePickerState.itemExtent,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: _PillDatePickerState.itemDiameter,
            height: _PillDatePickerState.itemDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.white : Colors.transparent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _days[date.weekday - 1],
                  style: TextStyle(
                    color: isActive ? _dark : _blue,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isActive ? _dark : _blue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Habit dialog helpers (used from edit toolbar)
// ═══════════════════════════════════════════════════════════

void _showAddDialog(BuildContext context, WidgetRef ref) {
  final nameCtrl = TextEditingController();
  final timeCtrl = TextEditingController(text: '08:00');
  final placeCtrl = TextEditingController();
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.deepSapphireDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text('New Habit', style: TextStyle(color: Colors.white)),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted))),
        TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              ref.read(habitProvider.notifier).add(Habit(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameCtrl.text.trim(),
                    time: timeCtrl.text.trim(),
                    place: placeCtrl.text.trim(),
                    iconCodePoint: Icons.star_rounded.codePoint,
                  ));
              Navigator.pop(context);
            },
            child: const Text('Add',
                style: TextStyle(color: AppColors.glowingBlue))),
      ],
    ),
  );
}

void _showEditDialog(BuildContext context, WidgetRef ref) {
  final habits = ref.read(habitProvider);
  if (habits.isEmpty) return;
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.deepSapphireDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text('Edit Habit', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: habits.length,
          itemBuilder: (ctx, i) => ListTile(
            leading: Icon(
                IconData(habits[i].iconCodePoint, fontFamily: 'MaterialIcons'),
                color: AppColors.glowingBlue),
            title: Text(habits[i].name,
                style: const TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _editSingle(ctx, ref, habits[i]);
            },
          ),
        ),
      ),
    ),
  );
}

void _editSingle(BuildContext context, WidgetRef ref, Habit habit) {
  final nameCtrl = TextEditingController(text: habit.name);
  final timeCtrl = TextEditingController(text: habit.time);
  final placeCtrl = TextEditingController(text: habit.place);
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.deepSapphireDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text('Edit', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dialogField(nameCtrl, 'Name'),
          const SizedBox(height: 8),
          _dialogField(timeCtrl, 'Time'),
          const SizedBox(height: 8),
          _dialogField(placeCtrl, 'Place'),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted))),
        TextButton(
            onPressed: () {
              ref.read(habitProvider.notifier).edit(
                    habit.id,
                    name: nameCtrl.text.trim(),
                    time: timeCtrl.text.trim(),
                    place: placeCtrl.text.trim(),
                  );
              Navigator.pop(context);
            },
            child: const Text('Save',
                style: TextStyle(color: AppColors.glowingBlue))),
      ],
    ),
  );
}

void _showDeleteDialog(BuildContext context, WidgetRef ref) {
  final habits = ref.read(habitProvider);
  if (habits.isEmpty) return;
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.deepSapphireDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title:
          const Text('Delete Habit', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: habits.length,
          itemBuilder: (ctx, i) => ListTile(
            leading: Icon(
                IconData(habits[i].iconCodePoint, fontFamily: 'MaterialIcons'),
                color: AppColors.error),
            title: Text(habits[i].name,
                style: const TextStyle(color: Colors.white)),
            onTap: () {
              ref.read(habitProvider.notifier).delete(habits[i].id);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    ),
  );
}

Widget _dialogField(TextEditingController controller, String hint) {
  return TextField(
    controller: controller,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none),
    ),
  );
}

// ═══════════════════════════════════════════════════════════
//  Habit Card Stack — swipeable cards with multi-select
//  True rounded corners via ClipRRect on every card
// ═══════════════════════════════════════════════════════════

class _HabitCardStack extends ConsumerWidget {
  const _HabitCardStack({
    required this.selectedIds,
    required this.onToggleSelect,
  });

  final Set<String> selectedIds;
  final void Function(String) onToggleSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final devMode = ref.watch(devModeProvider);
    final notifier = ref.read(habitProvider.notifier);

    if (habits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.spa_outlined,
                  size: 64,
                  color: AppColors.textMuted.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              const Text('No habits yet!',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: habits.map((habit) {
        final dateKey = Habit.dateKey(selectedDate);
        final status = habit.completions[dateKey]; // 'done' or 'skip' or null
        final done = status == 'done';
        final skipped = status == 'skip';
        final isSelected = selectedIds.contains(habit.id);

        final now = DateTime.now();
        final isToday = selectedDate.year == now.year &&
            selectedDate.month == now.month &&
            selectedDate.day == now.day;

        final DismissDirection swipeDirection;
        if (!isToday) {
          swipeDirection = DismissDirection.none;
        } else if (done) {
          swipeDirection = DismissDirection.none;
        } else if (skipped) {
          swipeDirection = DismissDirection.startToEnd;
        } else {
          swipeDirection = DismissDirection.horizontal;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Dismissible(
              key: ValueKey('${habit.id}_$dateKey'),
              direction: swipeDirection,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  notifier.markDone(habit.id, selectedDate);
                  notifier.moveToBottom(habit.id);
                } else {
                  notifier.markSkip(habit.id, selectedDate);
                  notifier.moveToBottom(habit.id);
                }
                return false;
              },
              // Swipe LEFT background → Done (green)
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 32),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 28),
                    SizedBox(width: 8),
                    Text('Done',
                        style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ],
                ),
              ),
              // Swipe RIGHT background → Skip (amber)
              secondaryBackground: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 32),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Skip',
                        style: TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    SizedBox(width: 8),
                    Icon(Icons.skip_next_rounded,
                        color: AppColors.warning, size: 28),
                  ],
                ),
              ),
              child: GestureDetector(
                onLongPress: devMode ? () => onToggleSelect(habit.id) : null,
                child: GlassCard(
                  margin: EdgeInsets.zero,
              child: Container(
                decoration: isSelected
                    ? BoxDecoration(
                        border: Border.all(
                            color: AppColors.glowingBlue, width: 2),
                        borderRadius: BorderRadius.circular(24),
                      )
                    : null,
                child: Row(
                  children: [
                    // Selection indicator in edit mode
                    if (devMode)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected
                              ? AppColors.glowingBlue
                              : AppColors.textMuted.withValues(alpha: 0.4),
                          size: 22,
                        ),
                      ),
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: done
                            ? AppColors.success.withValues(alpha: 0.2)
                            : skipped
                                ? AppColors.warning.withValues(alpha: 0.2)
                                : AppColors.glowingBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        IconData(habit.iconCodePoint,
                            fontFamily: 'MaterialIcons'),
                        color: done
                            ? AppColors.success
                            : skipped
                                ? AppColors.warning
                                : AppColors.glowingBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: done || skipped
                                  ? AppColors.textMuted
                                  : Colors.white,
                              decoration: done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Habit time, place, and completion badge
                          Row(
                            children: [
                              if (habit.time.isNotEmpty) ...[
                                Icon(Icons.access_time,
                                    size: 14, color: AppColors.glowingBlue),
                                const SizedBox(width: 4),
                                Text(habit.time,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                                const SizedBox(width: 12),
                              ],
                              if (habit.place.isNotEmpty) ...[
                                Icon(Icons.location_on_outlined,
                                    size: 14, color: AppColors.glowingBlue),
                                const SizedBox(width: 4),
                                Text(habit.place,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                              ],
                              const Spacer(),
                              if (done)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('Done',
                                      style: TextStyle(
                                          color: AppColors.success,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                )
                              else if (skipped)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('Skipped',
                                      style: TextStyle(
                                          color: AppColors.warning,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Weekly Progress Line Chart — syncs with selected date
// ═══════════════════════════════════════════════════════════

class _WeeklyChart extends ConsumerWidget {
  const _WeeklyChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    if (habits.isEmpty) return const SizedBox.shrink();

    // ── Use selected date to compute the week ──
    final selected = ref.watch(selectedDateProvider);
    final monday = selected.subtract(Duration(days: selected.weekday - 1));

    final spots = <FlSpot>[];
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final key = Habit.dateKey(day);
      int done = 0;
      for (final h in habits) {
        if (h.completions[key] == 'done') done++;
      }
      spots.add(FlSpot(i.toDouble(), (done / habits.length) * 100));
    }

    // Build day labels relative to the selected week
    final dayLabels = List.generate(7, (i) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[i];
    });

    return GlassCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Weekly Progress',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const Spacer(),
              // Show which week we're viewing
              Text(
                '${monday.day}/${monday.month} – ${monday.add(const Duration(days: 6)).day}/${monday.add(const Duration(days: 6)).month}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withValues(alpha: 0.06),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(dayLabels[value.toInt()],
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) {
                      return spots
                          .map((s) => LineTooltipItem(
                                '${s.y.toInt()}%',
                                const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ))
                          .toList();
                    },
                  ),
                ),
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
                      getDotPainter: (spot, xPercentage, bar, index) =>
                          FlDotCirclePainter(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
