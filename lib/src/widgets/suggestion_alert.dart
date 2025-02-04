import 'package:flutter/material.dart';
import 'album_image.dart';

class SuggestionAlert extends StatelessWidget {
  final String? imgUrl;
  final String message;
  final void Function() onPressedRandom;

  const SuggestionAlert({
    super.key,
    required this.message,
    required this.onPressedRandom,
    this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('You should listen to:'),
      content: imgUrl != null && imgUrl!.isNotEmpty
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    width: 200,
                    height: 200,
                    child: AlbumImage(thumbUrl: imgUrl, size: 200)),
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
            onPressedRandom();
          },
        ),
      ],
    );
  }
}
