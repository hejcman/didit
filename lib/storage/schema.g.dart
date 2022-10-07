// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemoryAdapter extends TypeAdapter<Memory> {
  @override
  final int typeId = 1;

  @override
  Memory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Memory(
      fields[0] as DateTime,
      fields[1] as Uint8List,
      fields[2] as LifetimeTag,
    );
  }

  @override
  void write(BinaryWriter writer, Memory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.created)
      ..writeByte(1)
      ..write(obj.pictureBytes)
      ..writeByte(2)
      ..write(obj.lifetimeTag);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LifetimeTagAdapter extends TypeAdapter<LifetimeTag> {
  @override
  final int typeId = 0;

  @override
  LifetimeTag read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LifetimeTag.oneDay;
      case 1:
        return LifetimeTag.sevenDays;
      case 2:
        return LifetimeTag.thirtyDays;
      default:
        return LifetimeTag.oneDay;
    }
  }

  @override
  void write(BinaryWriter writer, LifetimeTag obj) {
    switch (obj) {
      case LifetimeTag.oneDay:
        writer.writeByte(0);
        break;
      case LifetimeTag.sevenDays:
        writer.writeByte(1);
        break;
      case LifetimeTag.thirtyDays:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LifetimeTagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
