import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../models/album_moods.dart';
import '../models/collection_album.dart';
import '../services/collection_service.dart';
import '../services/moods_service.dart';
import '../services/openai_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _loadingNumber = 0;
  final _moodsService = MoodsService();
  final _openAiService = OpenAIService();
  final _collectionService = CollectionService();
  static final Logger _log = Logger('SettingScreen');

  _loadAlbumMoods(DbCollectionAlbum album) async {
    _log.info('Loading moods for ${album.artist} - ${album.title}');
    final loadedMoods = _moodsService.getAlbumMoods(album.releaseId);
    if (loadedMoods != null) {
      await Future.delayed(const Duration(milliseconds: 1));
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
  }

  _loadAllMoods() async {
    final collection = _collectionService.getAllCollections();
    for (final element in collection) {
      for (final album in element) {
        setState(() {
          _loadingNumber += 1;
        });
        await _loadAlbumMoods(album);
      }
    }
    setState(() {
      _loadingNumber = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int collectionLength = _collectionService
        .getAllCollections()
        .map((element) => element.length)
        .reduce((acc, element) => acc + element);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blueGrey,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Stack(
        children: [
          ListView(children: [
            const ListTile(
              title: Text('Syncronization Settings'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Get all moods'),
              onTap: _loadAllMoods,
            ),
          ]),
          if (_loadingNumber > 0)
            ModalBarrier(
              color: Colors.black.withAlpha(100),
              dismissible: false,
            ),
          if (_loadingNumber > 0)
            Center(
              child: LinearProgressIndicator(
                value: _loadingNumber / collectionLength,
              ),
            ),
        ],
      ),
    );
  }
}
