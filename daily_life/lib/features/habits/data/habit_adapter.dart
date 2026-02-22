import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit_model.dart';

// ═══════════════════════════════════════════════════════════
//  Hive Adapter for Habit (typeId: 2)
// ═══════════════════════════════════════════════════════════

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 2;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      time: fields[2] as String,
      place: fields[3] as String,
      iconCodePoint: fields[4] as int,
      completions: Map<String, String>.from(
        fields[5] as Map<dynamic, dynamic>? ?? {},
      ),
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.place)
      ..writeByte(4)
      ..write(obj.iconCodePoint)
      ..writeByte(5)
      ..write(obj.completions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
