import '../models/collection_album.dart';
import 'package:flutter/material.dart';

import 'album_image.dart';

class AlbumList extends StatelessWidget {
  final List<DbCollectionAlbum> albums;
  final void Function(DbCollectionAlbum album) onLongPress;

  const AlbumList({super.key, required this.albums, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return ListTile(
          leading: SizedBox(
            width: 60,
            child: AlbumImage(thumbUrl: album.thumbUrl ?? '', size: 60),
          ),
          title: Text(album.title),
          subtitle: Text('${album.artist} - ${album.year}'),
          onLongPress: () => onLongPress(album),
        );
      },
    );
  }
}
