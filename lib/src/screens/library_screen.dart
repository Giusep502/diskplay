import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/discogs_model.dart';
import '../utils/database_helper.dart';
import '../widgets/errors.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _library = [];
  bool _isLoading = false;
  final TextEditingController _controller = TextEditingController();
  final _discogsCollection = Collection('Diskplay/0.1');
  static final Logger _log = Logger('LibraryScreen');
  final _placeholder = Image.asset('assets/images/vinyl_placeholder.jpg');

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

  Image getImage(String? thumbUrl, int size) {
    return thumbUrl != null && thumbUrl.isNotEmpty
        ? Image.network(thumbUrl,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              }
            },
            errorBuilder: (context, error, stackTrace) => _placeholder)
        : _placeholder;
  }

  void _showAlert(String message, String? imgUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('You should listen to:'),
          content: imgUrl != null && imgUrl.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                        width: 200, height: 200, child: getImage(imgUrl, 200)),
                    Text(message)
                  ],
                )
              : Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('NO, another one!'),
              onPressed: () {
                Navigator.of(context).pop();
                _onPressedRandom();
              },
            ),
          ],
        );
      },
    );
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
              : ListView.builder(
                  itemCount: _discogsCollection.albums.length,
                  itemBuilder: (context, index) {
                    final album = _discogsCollection.albums[index];
                    return ListTile(
                      leading: SizedBox(
                          width: 60, child: getImage(album.thumbUrl, 60)),
                      title: Text(album.title),
                      subtitle: Text('${album.artist} - ${album.year}'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
