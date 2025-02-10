// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_album.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DbCollectionAlbumAdapter extends TypeAdapter<DbCollectionAlbum> {
  @override
  final int typeId = 1;

  @override
  DbCollectionAlbum read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DbCollectionAlbum(
      releaseId: fields[4] as int,
      artist: fields[1] as String,
      title: fields[0] as String,
      formats: (fields[5] as List).cast<DbAlbumFormat>(),
      year: fields[3] as int,
      thumbUrl: fields[2] as String?,
      rating: fields[6] as int?,
      dateAdded: fields[7] as String?,
      genres: (fields[8] as List).cast<String>(),
      styles: (fields[9] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, DbCollectionAlbum obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.artist)
      ..writeByte(2)
      ..write(obj.thumbUrl)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.releaseId)
      ..writeByte(5)
      ..write(obj.formats)
      ..writeByte(6)
      ..write(obj.rating)
      ..writeByte(7)
      ..write(obj.dateAdded)
      ..writeByte(8)
      ..write(obj.genres)
      ..writeByte(9)
      ..write(obj.styles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbCollectionAlbumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
