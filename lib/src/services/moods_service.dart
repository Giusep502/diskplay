import 'package:hive/hive.dart';

import '../models/album_moods.dart';

class MoodsService {
  final Box _box = Hive.box('moodsBox');

  MoodsService();

  DbAlbumMoods? getAlbumMoods(int formatId) {
    final moods = _box.get(formatId);
    return moods;
  }

  Future<void> saveAlbumMoods(DbAlbumMoods moods, int formatId) async {
    await _box.put(formatId, moods);
  }

  List<int> getLoadedAlbums() {
    return _box.keys.cast<int>().toList();
  }

  List<String> getAllMoods() {
    return _box.values
        .toList()
        .map((e) => (e as DbAlbumMoods).moods)
        .expand((element) => element)
        .toSet()
        .toList();
  }

  List<DbAlbumMoods> getAlbumsByMood(String mood) {
    return _box.values
        .where((element) => (element as DbAlbumMoods).moods.contains(mood))
        .toList()
        .cast();
  }

  Future<void> deleteAlbumMoods(String username) async {
    await _box.delete(username);
  }
}
