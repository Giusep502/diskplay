import 'package:hive/hive.dart';

part 'collection_album.g.dart';

@HiveType(typeId: 0)
class CollectionAlbum {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String artist;

  @HiveField(2)
  final String thumbUrl;

  @HiveField(3)
  final int year;

  CollectionAlbum({
    required this.title,
    required this.artist,
    required this.thumbUrl,
    required this.year,
  });
}
