import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
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
    if (_discogsCollection.albums.isEmpty) {
      _showAlert('Please synchronize your collection first', null);
    }

    final randomized = [..._discogsCollection.albums];
    randomized.shuffle();
    _showAlert('${randomized[0].artist} - ${randomized[0].title}',
        randomized[0].thumbUrl);
  }

  @override
  Widget build(BuildContext context) {
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
                Text('${_discogsCollection.albums.length.toString()} albums'),
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
              : AlbumList(albums: _discogsCollection.albums),
        ),
      ],
    );
  }
}
