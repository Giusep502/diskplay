import 'package:hive/hive.dart';

import 'album_format.dart';

part 'collection_album.g.dart';

abstract class Album {
  int get releaseId;
  String get artist;
  String get title;
  String? get thumbUrl;
}

@HiveType(typeId: 1)
class DbCollectionAlbum implements Album {
  @override
  @HiveField(0)
  final String title;
  @override
  @HiveField(1)
  final String artist;
  @override
  @HiveField(2)
  final String? thumbUrl;

  @HiveField(3)
  final int year;
  @override
  @HiveField(4)
  final int releaseId;

  @HiveField(5)
  final List<DbAlbumFormat> formats;

  @HiveField(6)
  final int? rating;
  @HiveField(7)
  final String? dateAdded;
  @HiveField(8)
  final List<String> genres;
  @HiveField(9)
  final List<String> styles;

  DbCollectionAlbum(
      {required this.releaseId,
      required this.artist,
      required this.title,
      required this.formats,
      required this.year,
      required this.thumbUrl,
      required this.rating,
      required this.dateAdded,
      required this.genres,
      required this.styles});
}
