import 'package:flutter/material.dart';

class AlbumImage extends StatelessWidget {
  final String? thumbUrl;
  final int size;
  final _placeholder = 'assets/images/vinyl_placeholder.jpg';

  const AlbumImage({
    super.key,
    this.thumbUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return thumbUrl != null && thumbUrl!.isNotEmpty
        ? Image.network(thumbUrl!,
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
            errorBuilder: (context, error, stackTrace) =>
                Image.asset(_placeholder))
        : Image.asset(_placeholder);
  }
}
