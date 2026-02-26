import 'package:hive_flutter/hive_flutter.dart';

import 'todo_model.dart';

// ═══════════════════════════════════════════════════════════
//  Hive Adapter for TodoTask (typeId: 3)
// ═══════════════════════════════════════════════════════════

class TodoTaskAdapter extends TypeAdapter<TodoTask> {
  @override
  final int typeId = 3;

  @override
  TodoTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoTask(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String? ?? '',
      deadline: fields[3] as DateTime,
      priority: TaskPriority.values[fields[4] as int],
      tag: fields[5] as String? ?? 'Personal',
      status: TaskStatus.values[fields[6] as int],
    );
  }

  @override
  void write(BinaryWriter writer, TodoTask obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.deadline)
      ..writeByte(4)
      ..write(obj.priority.index)
      ..writeByte(5)
      ..write(obj.tag)
      ..writeByte(6)
      ..write(obj.status.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
