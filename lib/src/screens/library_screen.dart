import 'package:diskplay_app/src/services/collection_service.dart';
import 'package:diskplay_app/src/services/moods_service.dart';
import 'package:diskplay_app/src/services/openai_service.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/album_moods.dart';
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
  String _selectedArtist = '';
  String _selectedUser = '';

  final TextEditingController _controller = TextEditingController();
  final _discogsCollection = Collection('Diskplay/0.1');
  final _collectionService = CollectionService();
  final _moodsService = MoodsService();
  final _openAiService = OpenAIService();
  static final Logger _log = Logger('LibraryScreen');

  void _onPressed() async {
    /** TODO: FIX loading workaround to notify changes */
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

  void _showAlert(String title, String message, String? imgUrl) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SuggestionAlert(
            title: title,
            message: message,
            imgUrl: imgUrl,
          );
        });
  }

  void _loadAlbumMoods(DbCollectionAlbum album) async {
    final loadedMoods = _moodsService.getAlbumMoods(album.releaseId);
    if (loadedMoods != null) {
      _showAlert(album.title,
          '${album.artist} - ${loadedMoods.moods.toString()}', album.thumbUrl);
      return;
    }
    final moods = await _openAiService.getMoodsFromAlbum(
        album.artist, album.title, album.year.toString());
    final albumMoods = DbAlbumMoods(
        moods: moods,
        artist: album.artist,
        title: album.title,
        year: album.year);
    _moodsService.saveAlbumMoods(albumMoods, album.releaseId);
    _showAlert(
        album.title, '${album.artist} - ${moods.toString()}', album.thumbUrl);
  }

  @override
  Widget build(BuildContext context) {
    final collection = _collectionService.getAllCollections();
    final users = _collectionService.getUsers();
    final flatCollection = _selectedUser.isEmpty
        ? collection.expand((element) => element)
        : _collectionService.getUserCollection(_selectedUser)!;
    final filteredCollection = flatCollection.where((album) {
      return _selectedArtist.isEmpty || album.artist == _selectedArtist;
    }).toList();
    final artists = flatCollection.map((album) => album.artist).toSet();

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
              const SizedBox(width: 8.0),
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
            spacing: 8.0,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                hint: const Text('Select Artist'),
                value: _selectedArtist.isEmpty ? null : _selectedArtist,
                onChanged: (value) {
                  setState(() {
                    _selectedArtist = value ?? '';
                  });
                },
                items: artists
                    .map((artist) => DropdownMenuItem(
                          value: artist.toString(),
                          child: Text(artist),
                        ))
                    .toList(),
              ),
              DropdownButton<String>(
                hint: const Text('Select User'),
                value: _selectedUser.isEmpty ? null : _selectedUser,
                onChanged: (value) {
                  setState(() {
                    _selectedUser = value ?? '';
                  });
                },
                items: users
                    .map((user) => DropdownMenuItem(
                          value: user.toString(),
                          child: Text(user),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${filteredCollection.length} albums'),
                const SizedBox(width: 8.0), // Add space between Text and Button
                ActionChip(
                  label: const Text('Clear Filters'),
                  onPressed: () {
                    setState(() {
                      _selectedArtist = '';
                      _selectedUser = '';
                    });
                  },
                ),
              ],
            )),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredCollection.isNotEmpty
                  ? AlbumList(
                      albums:
                          filteredCollection.cast<DbCollectionAlbum>().toList(),
                      onLongPress: _loadAlbumMoods,
                    )
                  : const Center(
                      child: Text('No data'),
                    ),
        ),
      ],
    );
  }
}
