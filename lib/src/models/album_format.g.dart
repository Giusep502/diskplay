// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album_format.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DbAlbumFormatAdapter extends TypeAdapter<DbAlbumFormat> {
  @override
  final int typeId = 0;

  @override
  DbAlbumFormat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DbAlbumFormat(
      formatName: fields[0] as String,
      extraText: fields[1] as String?,
      descriptions: (fields[2] as List?)?.cast<String>(),
      quantity: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DbAlbumFormat obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.formatName)
      ..writeByte(1)
      ..write(obj.extraText)
      ..writeByte(2)
      ..write(obj.descriptions)
      ..writeByte(3)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbAlbumFormatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
