// Inspired by Scrobbler App, Copyright (c) 2020 Filipe Tavares

import 'package:diskplay_app/src/services/collection_service.dart';
import 'package:flutter/foundation.dart';
import 'package:diacritic/diacritic.dart';
import 'package:logging/logging.dart';

import '../services/discogs_service.dart';
import '../utils/errors.dart';
import 'album_format.dart';
import 'collection_album.dart';

String _normalizeSearchString(String s) => removeDiacritics(s).toLowerCase();

class CollectionAlbum extends DbCollectionAlbum {
  CollectionAlbum(
      {required this.id,
      required super.releaseId,
      required super.artist,
      required super.title,
      required super.formats,
      required super.year,
      required super.thumbUrl,
      required super.rating,
      required super.dateAdded,
      required super.genres,
      required super.styles})
      : searchString = _normalizeSearchString('$artist $title');

  factory CollectionAlbum.fromJson(Map<String, dynamic> json) {
    final info = json['basic_information'] as Map<String, dynamic>;
    return CollectionAlbum(
      id: json['instance_id'] as int,
      releaseId: json['id'] as int,
      artist: _oneNameForArtists(info['artists'] as List<dynamic>),
      title: info['title'] as String,
      formats: (info['formats'] as List<dynamic>?)
              ?.map((format) => AlbumFormat.fromJson(format))
              .toList() ??
          [],
      year: info['year'] as int,
      thumbUrl: info['thumb'] as String?,
      rating: json['rating'] as int?,
      dateAdded: json['date_added'] as String?,
      genres: (info['genres'] as List<dynamic>?)
              ?.map((genre) => genre as String)
              .toList() ??
          [],
      styles: (info['styles'] as List<dynamic>?)
              ?.map((genre) => genre as String)
              .toList() ??
          [],
    );
  }

  final int id;
  final String searchString;
}

class AlbumFormat extends DbAlbumFormat {
  AlbumFormat(
      {required super.formatName,
      super.extraText,
      super.descriptions,
      required super.quantity})
      : name = formatName;

  final String name;

  factory AlbumFormat.fromJson(Map<String, dynamic> json) {
    return AlbumFormat(
      formatName: json['name'],
      extraText: json['text'],
      descriptions: (json['descriptions'] as List<dynamic>?)
              ?.map((description) => description as String)
              .toList() ??
          [],
      quantity: int.tryParse(json['qty']) ?? 1,
    );
  }

  @override
  String toString() {
    var string = '${quantity > 1 ? '$quantity x ' : ''}$name';
    if (extraText?.isNotEmpty ?? false) {
      string += ' $extraText';
    }
    if (descriptions?.isNotEmpty ?? false) {
      string += ' (${descriptions!.join(', ')})';
    }
    return string;
  }
}

class AlbumDetails implements Album {
  AlbumDetails({
    required this.releaseId,
    required this.artist,
    required this.title,
    required this.thumbUrl,
    required this.tracks,
  });

  factory AlbumDetails.fromJson(Map<String, dynamic> json) {
    return AlbumDetails(
      releaseId: json['id'] as int,
      artist: _oneNameForArtists(json['artists'] as List<dynamic>),
      title: json['title'] as String,
      thumbUrl: json['thumb'] as String?,
      tracks: (json['tracklist'] as List<dynamic>)
          .where((track) => track['type_'] != 'heading')
          .map<AlbumTrack>((track) => AlbumTrack.fromJson(track))
          .toList(),
    );
  }

  @override
  final int releaseId;
  @override
  final String artist;
  @override
  final String title;
  @override
  final String? thumbUrl;
  final List<AlbumTrack> tracks;
}

class AlbumTrack {
  AlbumTrack({
    required this.title,
    this.position,
    this.duration,
    this.artist,
    this.subTracks,
  });

  factory AlbumTrack.fromJson(Map<String, dynamic> json) {
    List<dynamic>? artists =
        json['artists'] as List<dynamic>?; // optional for tracks
    // parse duration
    String? durationString = json['duration'] as String?;
    final splitDuration = (durationString != null && durationString.isNotEmpty)
        ? durationString.split(':').map<int>(int.parse)
        : null;
    final durationInSeconds = splitDuration?.reduce((v, e) => v * 60 + e);

    return AlbumTrack(
      title: json['title'] as String,
      position: json['position'] as String?,
      duration: durationInSeconds,
      artist: (artists == null || artists.isEmpty)
          ? null
          : _oneNameForArtists(artists),
      subTracks: (json['sub_tracks'] as List<dynamic>?)
          ?.map<AlbumTrack>((subTrack) => AlbumTrack.fromJson(subTrack))
          .toList(),
    );
  }

  final String title;
  final String? position;
  final int? duration;
  final String? artist;
  final List<AlbumTrack>? subTracks;
}

class Collection {
  Collection(this.userAgent) : _discogsService = DiscogsService(userAgent);

  final DiscogsService _discogsService;
  final CollectionService _collectionService = CollectionService();
  final String userAgent;

  String? _username;
  final List<CollectionAlbum> _albumList = <CollectionAlbum>[];

  final _Progress _progress = _Progress();

  int _nextPage = 1;
  int _totalItems = 0;
  int _totalPages = 0;

  ValueNotifier<LoadingStatus> get loadingNotifier => _progress.statusNotifier;

  bool get isLoading => _progress.status == LoadingStatus.loading;

  bool get isNotLoading => !isLoading;

  bool get hasLoadingError => _progress.status == LoadingStatus.error;

  String? get errorMessage => _progress.errorMessage;

  bool get isEmpty => _albumList.isEmpty;

  bool get isNotEmpty => !isEmpty;

  bool get isUserEmpty => _username == null;

  bool get isFullyLoaded => _nextPage > 1 && _nextPage > _totalPages;

  bool get isNotFullyLoaded => !isFullyLoaded;

  int get totalItems => _totalItems;

  int get totalPages => _totalPages;

  int get nextPage => _nextPage;

  bool get hasMorePages => _nextPage <= _totalPages;

  List<CollectionAlbum> get albums => _albumList;

  void _reset() {
    _albumList.clear();
    _nextPage = 1;
    _totalItems = 0;
    _totalPages = 0;
    _log.fine('Reset collection.');
  }

  void _clearAndAddAlbums(List<CollectionAlbum> albums) {
    _albumList.clear();
    _log.fine('Cleared all albums.');
    _addAlbums(albums);
  }

  void _addAlbums(List<CollectionAlbum> albums) {
    _albumList.addAll(albums);
    _collectionService.saveUserCollection(albums, _username!);
    _log.fine('Added ${albums.length} albums.');
  }

  Future<void> updateUsername(String? newUsername) async {
    newUsername = newUsername?.trim(); // remove white space around username

    if (newUsername != null && newUsername.isEmpty) {
      newUsername =
          null; // make sure empty (i.e. no) username is always saved as null
    }

    if (newUsername == _username) return;

    // If the username has changed, then we must remove any albums
    // that may have been loaded from the previous user's collection.
    _reset();
    _username = newUsername;

    if (_username != null) {
      _log.info(
          'Updated collection username to: $_username, reloading collection.');
      await reload();
    } else {
      _log.info('Collection username was removed.');
    }
  }

  Future<void> reload({bool emptyCache = false}) async {
    if (isLoading) {
      _log.info('Cannot reload yet because the collection is still loading...');
      return;
    }
    if (_username == null) {
      // throw UIException('Cannot load albums because the username is empty.');
    }

    _log.fine('Reloading collection for $_username...');

    _progress.loading();
    try {
      if (emptyCache) {
        await _discogsService.emptyCache();
      }
      _clearAndAddAlbums(await _loadCollectionPage(1));
      _nextPage = 2;

      _progress.finished();
    } catch (e) {
      _progress.error(e);
      rethrow;
    }
  }

  Future<void> loadMoreAlbums() async {
    if (isLoading) {
      _log.info(
          'Cannot load more yet because the collection is still loading...');
      return;
    }
    if (isFullyLoaded) {
      _log.info('Reached last page, not loading any more.');
      return;
    }
    if (_username == null) {
      _log.info('Cannot load albums because the username is empty.');
      return;
    }

    _progress.loading();
    try {
      _addAlbums(await _loadCollectionPage(_nextPage));
      _nextPage++;

      _progress.finished();
    } catch (e) {
      _progress.error(e);
      rethrow;
    }
  }

  Future<void> loadAllAlbums() async {
    if (isLoading) {
      _log.info(
          'Cannot load more yet because the collection is still loading...');
      return;
    }
    if (isFullyLoaded) {
      _log.info('Reached last page, not loading any more.');
      return;
    }
    if (_username == null) {
      throw UIException('Cannot load albums because the username is empty.');
    }
    if (_totalPages == 0) {
      throw UIException(
          'Cannot load all remaining albums before loading the first page.');
    }

    _progress.loading();
    try {
      final pages = await Future.wait<List<CollectionAlbum>>(
        <Future<List<CollectionAlbum>>>[
          for (int page = _nextPage; page <= _totalPages; page++)
            _loadCollectionPage(page)
        ],
        eagerError: true,
      );

      pages.forEach(_addAlbums);

      _nextPage = 0; // setting page index to the start

      _progress.finished();
    } catch (e) {
      _progress.error(e);
      rethrow;
    }
  }

  Future<List<CollectionAlbum>> _loadCollectionPage(int pageNumber) async {
    final response =
        await _discogsService.loadCollectionPage(_username!, pageNumber);
    _totalItems = response.pageInfo['items'] as int;
    _totalPages = response.pageInfo['pages'] as int;
    return response.releases
        .map((dynamic release) =>
            CollectionAlbum.fromJson(release as Map<String, dynamic>))
        .toList();
  }

  List<CollectionAlbum> search(String query) {
    final queries = _normalizeSearchString(query).split(RegExp(r'\s+'));

    return _albumList
        .where((album) => queries.every((q) => album.searchString.contains(q)))
        .toList();
  }

  Future<AlbumDetails> loadAlbumDetails(int releaseId) async {
    _log.info('Loading album details for: $releaseId');

    return AlbumDetails.fromJson(
        await _discogsService.loadAlbumDetails(releaseId));
  }

  static final Logger _log = Logger('Collection');
}

enum LoadingStatus { neverLoaded, loading, finished, error }

class _Progress {
  final ValueNotifier<LoadingStatus> statusNotifier =
      ValueNotifier<LoadingStatus>(LoadingStatus.neverLoaded);
  String? errorMessage;

  LoadingStatus get status => statusNotifier.value;

  void loading() {
    errorMessage = null;
    statusNotifier.value = LoadingStatus.loading;
  }

  void finished() {
    errorMessage = null;
    statusNotifier.value = LoadingStatus.finished;
  }

  void error(Object exception) {
    errorMessage = exception is UIException ? exception.message : null;
    statusNotifier.value = LoadingStatus.error;
  }
}

String _oneNameForArtists(List<dynamic> artists) {
  return (artists[0]['name'] as String).replaceAllMapped(
    RegExp(r'^(.+) \([0-9]+\)$'),
    (m) => m[1]!,
  );
}
