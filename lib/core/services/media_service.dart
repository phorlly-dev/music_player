import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart' show rootBundle;
import 'package:music_player/core/models/audio_file.dart';
import 'package:just_audio/just_audio.dart';

class MediaService {
  final List<AudioFile> _songs = [];

  List<AudioFile> get songs => _songs;

  // Load pre-bundled asset audio and image files
  Future<void> loadAssetFiles() async {
    _songs.clear();
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    // Filter audio files from assets/audios
    final audioAssets = manifestMap.keys
        .where((String key) => key.startsWith('assets/audios/'))
        .toList();
    for (String audioPath in audioAssets) {
      final audioFile = await _createAudioFileFromAsset(audioPath);
      _songs.add(audioFile);
    }
  }

  // Create AudioFile from asset path
  Future<AudioFile> _createAudioFileFromAsset(String audioPath) async {
    final fileName = audioPath.split('/').last;
    String title = fileName.split('.').first;
    String artist = 'Unknown Artist';
    String album = 'Unknown Album';
    Duration duration = Duration.zero;

    // Get duration using just_audio
    final player = AudioPlayer();
    try {
      await player.setAudioSource(AudioSource.asset(audioPath));
      duration = player.duration ?? Duration.zero;
    } catch (e) {
      log("Error getting duration for $audioPath: $e");
    } finally {
      await player.dispose();
    }

    // Match with an image (simple matching by filename)
    String artworkUrl =
        'assets/images/$title.png'; // Assume matching image name
    if (!await _assetExists(artworkUrl)) {
      artworkUrl = ''; // No matching artwork
    }

    return AudioFile(
      id: audioPath.hashCode.toString(),
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      url: audioPath,
      artworkUrl: artworkUrl,
      isFavorite: false,
      playlists: [],
    );
  }

  // Check if an asset exists
  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Add, edit, remove, favorite, playlist methods (as before)
  void add(AudioFile audioFile) => _songs.add(audioFile);
  void release(AudioFile audioFile) {
    final index = _songs.indexWhere((song) => song.id == audioFile.id);
    if (index != -1) _songs[index] = audioFile;
  }

  void remove(String id) => _songs.removeWhere((song) => song.id == id);
  void toggleFavorite(String id) {
    final index = _songs.indexWhere((song) => song.id == id);
    if (index != -1) {
      _songs[index] = _songs[index].copyWith(
        isFavorite: !_songs[index].isFavorite,
      );
    }
  }

  void addToPlaylist(String id, String playlistName) {
    final index = _songs.indexWhere((song) => song.id == id);
    if (index != -1 && !_songs[index].playlists.contains(playlistName)) {
      _songs[index].playlists.add(playlistName);
    }
  }

  void removeFromPlaylist(String id, String playlistName) {
    final index = _songs.indexWhere((song) => song.id == id);
    if (index != -1) _songs[index].playlists.remove(playlistName);
  }

  Stream<List<AudioFile>> get songsStream => Stream.value(_songs);
}

// Extension for copyWith
extension AudioFileExtension on AudioFile {
  AudioFile copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    String? url,
    String? artworkUrl,
    bool? isFavorite,
    List<String>? playlists,
  }) {
    return AudioFile(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      url: url ?? this.url,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      playlists: playlists ?? this.playlists,
    );
  }
}
