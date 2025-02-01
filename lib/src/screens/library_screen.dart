import 'package:flutter/material.dart';
import '../models/discogs_model.dart';
import '../utils/database_helper.dart';

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

  @override
  void initState() {
    super.initState();
  }

  void _onPressed() async {
    _discogsCollection.updateUsername(_controller.text);
    _isLoading = true;
    await _discogsCollection.loadAllAlbums();
    _isLoading = false;
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('You should listen to:'),
          content: Text(message),
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
      _showAlert('Please synchronize your collection first');
    }
    final randomized = [..._discogsCollection.albums];
    randomized.shuffle();
    _showAlert('${randomized[0].artist} - ${randomized[0].title}');
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
