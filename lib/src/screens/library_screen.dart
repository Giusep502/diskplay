import 'package:flutter/material.dart';
import '../utils/database_helper.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _library = [];

  @override
  void initState() {
    super.initState();
    _fetchLibrary();
  }

  Future<void> _fetchLibrary() async {
    final data = await _dbHelper.queryAll();
    setState(() {
      _library = data;
    });
  }

  Future<void> _addSong() async {
    await _dbHelper.insert({
      'title': 'New Song',
      'artist': 'Unknown Artist',
      'album': 'Unknown Album',
      'duration': 180,
    });
    _fetchLibrary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _library.length,
        itemBuilder: (context, index) {
          final song = _library[index];
          return ListTile(
            title: Text(song['title']),
            subtitle: Text('${song['artist']} - ${song['album']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSong,
        child: const Icon(Icons.add),
      ),
    );
  }
}
