// Inspired by Scrobbler App, Copyright (c) 2020 Filipe Tavares

import 'dart:convert';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../secrets.dart';
import '../utils/errors.dart';

abstract class AlbumResponse {
  List<dynamic> get releases;
  Map<String, dynamic> get pageInfo;
}

class _AlbumResponseImpl implements AlbumResponse {
  _AlbumResponseImpl(this.releases, this.pageInfo);

  @override
  final List<dynamic> releases;

  @override
  final Map<String, dynamic> pageInfo;
}

class DiscogsService {
  DiscogsService(this.userAgent);

  static const int _pageSize = 99;
  final String userAgent;
  final http.Client fallbackClient = http.Client();
  static final CacheManager cache = CacheManager(
    Config(
      'scrobblerCache',
      stalePeriod: const Duration(days: 30),
    ),
  );
  static final Logger _log = Logger('DiscogsService');

  Map<String, String> get _headers => <String, String>{
        'Authorization': 'Discogs key=$_consumerKey, secret=$_consumerSecret',
        'User-Agent': userAgent,
      };

  Future<Map<String, dynamic>> get(String apiPath) async {
    final url = 'https://api.discogs.com$apiPath';
    late String content;

    try {
      content = (await cache.getSingleFile(url, headers: _headers))
          .readAsStringSync();
    } on SocketException catch (e) {
      throw UIException(
          'Could not connect to Discogs. Please check your internet connection and try again later.',
          e);
    } on HttpExceptionWithStatus catch (e) {
      // If that response was not OK, throw an error.
      if (e.statusCode == 401) {
        throw UIException('''
Unfortunately your collection is not public, so the app can't access it.\n
To use this app, please go to discogs.com and change your collection to public.''');
      } else if (e.statusCode == 404) {
        throw UIException(
            'Oops! Couldn\'t find what you\'re looking for on Discogs (404 error).',
            e);
      } else if (e.statusCode >= 400) {
        throw UIException(
            'The Discogs service is currently unavailable (${e.statusCode}). Please try again later.',
            e);
      }
    } on HttpException catch (e) {
      // If that response was not OK, throw an error.
      throw UIException(
          'The Discogs service is currently unavailable. Please try again later.',
          e);
    } on FileSystemException catch (e) {
      _log.severe('Failed to read the cached file', e);
      // try falling back to direct download
      final response =
          await fallbackClient.get(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) {
        throw UIException(
            'The Discogs service is currently unavailable. Please try again later.',
            HttpException(
                'Fallback request to Discogs failed with status code: ${response.statusCode}'));
      }
      content = response.body;
    }

    return json.decode(content);
  }

  Future<void> emptyCache() async {
    await cache.emptyCache();
  }

  Future<AlbumResponse> loadCollectionPage(
      String username, int pageNumber) async {
    final page = await get(
        '/users/$username/collection/folders/0/releases?sort=added&sort_order=desc&per_page=$_pageSize&page=$pageNumber');

    final pageInfo = page['pagination'] as Map<String, dynamic>;
    final releases = page['releases'] as List<dynamic>;
    return _AlbumResponseImpl(releases, pageInfo);
  }

  Future<Map<String, dynamic>> loadAlbumDetails(int releaseId) async {
    final json = await get('/releases/$releaseId');
    return json;
  }

  static const String _consumerKey = discogsConsumerKey;
  static const String _consumerSecret = discogsConsumerSecret;
}
