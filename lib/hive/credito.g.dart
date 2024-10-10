// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credito.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreditoAdapter extends TypeAdapter<Credito> {
  @override
  final int typeId = 4;

  @override
  Credito read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Credito(
      id: fields[0] as int,
      credit: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Credito obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.credit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
