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

  void _showAlert(String message, String? imgUrl) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SuggestionAlert(
            message: message,
            onPressedRandom: _onPressedRandom,
            imgUrl: imgUrl,
          );
        });
  }

  void _showMoodAlert(String message, String? imgUrl, String mood) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SuggestionAlert(
            title: mood,
            message: message,
            onPressedRandom: () => _getAlbumOfMood(mood),
            imgUrl: imgUrl,
          );
        });
  }

  void _onPressedRandom() async {
    final flatCollection = _collectionService
        .getAllCollections()
        .expand((element) => element)
        .toList();
    if (flatCollection.isEmpty) {
      _showAlert('Please synchronize your collection first', null);
    }
    flatCollection.shuffle();
    _showAlert('${flatCollection[0].artist} - ${flatCollection[0].title}',
        flatCollection[0].thumbUrl);
  }

  void _getAlbumOfMood(String mood) {
    final albums = _moodsService.getAlbumsByMood(mood);
    albums.shuffle();
    final album = albums.isNotEmpty ? albums[0] : null;
    if (album != null) {
      final albumInfo =
          _collectionService.getAbumByTitleArtist(album.title, album.artist);
      _showMoodAlert(
          '${album.artist} - ${album.title}', albumInfo.thumbUrl, mood);
    }
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
