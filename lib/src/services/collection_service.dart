import '../models/collection_album.dart';
import 'package:hive/hive.dart';

class CollectionService {
  final Box _box = Hive.box('collectionBox');

  CollectionService();

  List<CollectionAlbum>? getUserCollection(String username) {
    List<dynamic>? userCollection = _box.get(username);
    return userCollection?.cast<CollectionAlbum>();
  }

  Future<void> saveUserCollection(
      List<dynamic> collection, String username) async {
    final userColl = getUserCollection(username) ?? [];
    for (var c in collection) {
      CollectionAlbum album = CollectionAlbum(
          title: c['title'],
          artist: c['artist'],
          thumbUrl: c['thumbUrl'],
          year: c['year']);
      userColl.add(album);
    }
    await _box.put(username, userColl);
  }

  List<String> getUsers() {
    return _box.keys.cast<String>().toList();
  }

  List<dynamic> getAllCollections() {
    return _box.values.toList();
  }

  Future<void> deleteUserCollection(String username) async {
    await _box.delete(username);
  }
}
