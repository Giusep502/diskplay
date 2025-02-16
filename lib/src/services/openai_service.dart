import 'dart:convert';
import 'package:diskplay_app/src/utils/errors.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../secrets.dart';

class OpenAIService {
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final String _bearerToken = openApiKey;
  static final Logger _log = Logger('OpenAiService');

  Future<Map<String, dynamic>> callOpenAi(String message) async {
    final url = _baseUrl;
    final response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_bearerToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content":
                  "Your entire response/output is going to consist of a single JSON object {}, and you will NOT wrap it within JSON md markers"
            },
            {"role": "user", "content": message}
          ],
          "temperature": 0.3
        }));

    if (response.statusCode == 200) {
      _log.info('OpenAI response: ${response.body}');
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw UIException('Failed to load data');
    }
  }

  Future<List<String>> getMoodsFromAlbum(
      String artist, String album, String year) async {
    String message =
        'What are the words that best represent the mood of the album $album by $artist released in $year?';
    message +=
        ' Provide a field called "moods" with a list of those words in an array';
    try {
      final response = await callOpenAi(message)
          .then((value) => value['choices'][0]['message']['content']);
      final moods = json.decode(response)['moods'] as List<dynamic>;
      _log.info('OpenAI moods: ${moods.toString()}');
      return moods.map((e) => e.toString()).toList();
    } on Exception catch (_) {
      throw UIException('Failed to parse ai message');
    }
  }
}
