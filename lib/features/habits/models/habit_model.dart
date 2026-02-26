import 'package:flutter/material.dart';

class Habit {
  Habit({
    required this.id,
    required this.name,
    required this.time,
    required this.place,
    required this.iconCodePoint,
    Map<String, String>? completions,
  }) : completions = completions ?? {};

  final String id;
  final String name;
  final String time; // e.g. "07:00"
  final String place;
  final int iconCodePoint;

  /// date-string → 'done' | 'skip'
  final Map<String, String> completions;

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool isDone(DateTime date) => completions[dateKey(date)] == 'done';
  bool isSkipped(DateTime date) => completions[dateKey(date)] == 'skip';
  bool isCompleted(DateTime date) => isDone(date) || isSkipped(date);

  /// Parse time string "HH:mm" to minutes since midnight for sorting.
  int get sortMinutes {
    final parts = time.split(':');
    if (parts.length == 2) {
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }
    return 0;
  }

  Habit copyWith({
    String? id,
    String? name,
    String? time,
    String? place,
    int? iconCodePoint,
    Map<String, String>? completions,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      place: place ?? this.place,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      completions: completions ?? Map.from(this.completions),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'time': time,
        'place': place,
        'iconCodePoint': iconCodePoint,
        'completions': completions,
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        name: json['name'] as String,
        time: json['time'] as String,
        place: json['place'] as String,
        iconCodePoint: json['iconCodePoint'] as int,
        completions: Map<String, String>.from(
            json['completions'] as Map<String, dynamic>? ?? {}),
      );
}
