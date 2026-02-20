import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: 1)
class JournalEntry extends HiveObject {
  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String tag;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  JournalEntry copyWith({
    String? title,
    String? content,
    String? tag,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      tag: tag ?? this.tag,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
