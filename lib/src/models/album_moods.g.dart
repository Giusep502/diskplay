// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album_moods.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DbAlbumMoodsAdapter extends TypeAdapter<DbAlbumMoods> {
  @override
  final int typeId = 2;

  @override
  DbAlbumMoods read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DbAlbumMoods(
      artist: fields[1] as String,
      title: fields[0] as String,
      year: fields[3] as int,
      moods: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, DbAlbumMoods obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(2)
      ..write(obj.moods);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbAlbumMoodsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
