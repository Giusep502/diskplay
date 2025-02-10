import '../models/discogs_model.dart';
import '../models/collection_album.dart';
import 'package:hive/hive.dart';

class CollectionService {
  final Box _box = Hive.box('collectionBox');

  CollectionService();

  List<DbCollectionAlbum>? getUserCollection(String username) {
    final userCollection = _box.get(username);
    return userCollection?.cast<DbCollectionAlbum>();
  }

  Future<void> saveUserCollection(
      List<CollectionAlbum> collection, String username) async {
    final userColl = getUserCollection(username) ?? [];
    for (var c in collection) {
      userColl.add(c);
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
