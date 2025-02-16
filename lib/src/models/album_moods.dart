import 'package:hive/hive.dart';

part 'album_moods.g.dart';

@HiveType(typeId: 2)
class DbAlbumMoods {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String artist;

  @HiveField(3)
  final int year;

  @HiveField(2)
  final List<String> moods;

  DbAlbumMoods(
      {required this.artist,
      required this.title,
      required this.year,
      required this.moods});
}
