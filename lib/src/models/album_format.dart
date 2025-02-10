import 'package:hive/hive.dart';

part 'album_format.g.dart';

@HiveType(typeId: 0)
class DbAlbumFormat {
  DbAlbumFormat(
      {required this.formatName,
      this.extraText,
      this.descriptions,
      required this.quantity});

  @HiveField(0)
  final String formatName;
  @HiveField(1)
  final String? extraText;
  @HiveField(2)
  final List<String>? descriptions;
  @HiveField(3)
  final int quantity;
}
