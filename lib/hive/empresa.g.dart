// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empresa.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmpresaAdapter extends TypeAdapter<Empresa> {
  @override
  final int typeId = 3;

  @override
  Empresa read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Empresa(
      id: fields[0] as String,
      title: fields[1] as String,
      imageBytes: fields[4] as Uint8List?,
      pointSale: fields[2] as String,
      seller: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Empresa obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.pointSale)
      ..writeByte(3)
      ..write(obj.seller)
      ..writeByte(4)
      ..write(obj.imageBytes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmpresaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
