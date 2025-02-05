// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_album.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CollectionAlbumAdapter extends TypeAdapter<CollectionAlbum> {
  @override
  final int typeId = 0;

  @override
  CollectionAlbum read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CollectionAlbum(
      title: fields[0] as String,
      artist: fields[1] as String,
      thumbUrl: fields[2] as String,
      year: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CollectionAlbum obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.artist)
      ..writeByte(2)
      ..write(obj.thumbUrl)
      ..writeByte(3)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionAlbumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
