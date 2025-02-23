import 'package:diskplay_app/src/models/collection_album.dart';
import 'package:flutter/material.dart';

import '../services/collection_service.dart';
import '../services/moods_service.dart';
import '../widgets/suggestion_alert.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _collectionService = CollectionService();
  final _moodsService = MoodsService();

  void _showMessage(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SuggestionAlert(
            message: message,
          );
        });
  }

  void _showAlert(List<DbCollectionAlbum> albums) {
    final album = albums.isNotEmpty ? albums[0] : null;
    if (album != null) {
      final message = '${album.artist} - ${album.title}';
      final imgUrl = album.thumbUrl;
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SuggestionAlert(
              message: message,
              onPressedRandom: () => _showAlert(albums.sublist(1)),
              imgUrl: imgUrl,
            );
          });
    } else {
      _showMessage('There are no more albums');
    }
  }

  void _onPressedRandom() async {
    final flatCollection = _collectionService
        .getAllCollections()
        .expand((element) => element)
        .toList();
    if (flatCollection.isEmpty) {
      _showMessage('Please synchronize your collection first');
    }
    flatCollection.shuffle();
    _showAlert(flatCollection.cast());
  }

  void _getAlbumOfMood(String mood) {
    final albums = _moodsService.getAlbumsByMood(mood);
    albums.shuffle();
    final moodAlbums = albums.map((album) =>
        _collectionService.getAbumByTitleArtist(album.title, album.artist));
    _showAlert(moodAlbums.toList());
  }

  @override
  Widget build(BuildContext context) {
    final moods = _moodsService.getAllMoods();
    return Column(spacing: 8.0, children: [
      const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Welcome to Diskplay! What should you listen to?")),
      ElevatedButton(
        onPressed: _onPressedRandom,
        child: const Text("Random Choice!"),
      ),
      if (moods.isNotEmpty)
        Expanded(
          child: ListView.builder(
              itemCount: moods.length,
              itemBuilder: (context, index) {
                final mood = moods[index];
                return ListTile(
                  title: Text(mood),
                  onTap: () => _getAlbumOfMood(mood),
                );
              }),
        )
    ]);
  }
}
