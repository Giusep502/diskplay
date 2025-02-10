import 'package:diskplay_app/src/services/collection_service.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/collection_album.dart';
import '../models/discogs_model.dart';
import '../widgets/album_list.dart';
import '../utils/errors.dart';
import '../widgets/suggestion_alert.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _isLoading = false;

  final TextEditingController _controller = TextEditingController();
  final _discogsCollection = Collection('Diskplay/0.1');
  final _collectionService = CollectionService();
  static final Logger _log = Logger('LibraryScreen');

  @override
  void initState() {
    super.initState();
  }

  void _onPressed() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _discogsCollection.updateUsername(_controller.text);
      await _discogsCollection.loadAllAlbums();
    } on Exception catch (e, stackTrace) {
      displayAndLogError(_log, e, stackTrace);
    }
    setState(() {
      _isLoading = false;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final collection = _collectionService.getAllCollections();
    final flatCollection = collection.expand((element) => element);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Discogs Username',
                  ),
                ),
              ),
              const SizedBox(
                  width: 8.0), // Add space between TextField and Button
              ElevatedButton(
                onPressed: _onPressed,
                child: const Text("Synchronize"),
              ),
            ],
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${flatCollection.length} albums'),
                const SizedBox(width: 8.0), // Add space between Text and Button
                ElevatedButton(
                  onPressed: _onPressedRandom,
                  child: const Text("What should I listen to?"),
                ),
              ],
            )),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : collection.isNotEmpty
                  ? AlbumList(
                      albums: flatCollection.cast<DbCollectionAlbum>().toList())
                  : const Center(
                      child: Text('No data loaded'),
                    ),
        ),
      ],
    );
  }
}
