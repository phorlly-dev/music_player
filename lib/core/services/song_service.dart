import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:music_player/core/models/song_file.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:music_player/core/services/service.dart';

class SongService extends Service with WidgetsBindingObserver {
  static const _databaseName = 'music_player.db';
  static const _databaseVersion = 1;
  static const _tableName = 'songs';

  static Database? _database;
  final _songsController = StreamController<List<SongFile>>.broadcast();
  bool _isFetching = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$_databaseName';
    // log('The path database: $path');
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            title TEXT,
            artist TEXT,
            album TEXT,
            duration INTEGER,
            url TEXT,
            artworkUrl TEXT,
            isFavorite INTEGER,
            playlists TEXT
          )
        ''');
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchSongFilesFromDevice();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _songsController.close();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isFetching) {
      fetchSongFilesFromDevice();
    }
  }

  // Notify listeners of changes
  Future<void> _notifyChanges() async {
    final songs = await _getAllSongs();
    // log('Emitting ${songs.length} songs to stream');

    _songsController.add(songs);
  }

  // Fetch audio files from device and save to database
  Future<List<SongFile>> fetchSongFilesFromDevice() async {
    if (_isFetching) return [];
    _isFetching = true;

    try {
      bool hasPermission = await permission();
      if (!hasPermission) {
        showSnackbar(
          'Permission Denied',
          'Storage permission is required to access audio files.',
        );
        return [];
      }

      final db = await database;
      final musicDir = Directory('/storage/emulated/0/Music');
      if (await musicDir.exists()) {
        await for (var entity in musicDir.list(recursive: true)) {
          if (entity is File) {
            String path = entity.path;
            String extension = path.split('.').last.toLowerCase();
            if (['mp3', 'wav', 'm4a', 'aac', 'ogg'].contains(extension)) {
              String newPath = await copyFileToAppStorage(path);
              SongFile audioFile = await _createAudioFileFromPath(newPath);
              await db.insert(
                _tableName,
                audioFile.toMap(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
        }
      }

      final songs = await _getAllSongs();
      _songsController.add(songs); // Emit updated data
      return songs;
    } catch (e) {
      log('Error fetching songs: $e');
      showSnackbar('Error', 'Failed to fetch songs: $e');
      return [];
    } finally {
      _isFetching = false;
    }
  }

  // Create AudioFile with metadata
  Future<SongFile> _createAudioFileFromPath(String path) async {
    final metadata = await MetadataRetriever.fromFile(File(path));
    final player = AudioPlayer();
    Duration duration = Duration.zero;
    try {
      await player.setAudioSource(AudioSource.file(path));
      duration = player.duration ?? Duration.zero;
    } catch (e) {
      log("Error getting duration for $path: $e");
    } finally {
      await player.dispose();
    }

    return SongFile(
      id: path.hashCode.toString(),
      title: metadata.trackName ?? path.split('/').last.split('.').first,
      artist: metadata.trackArtistNames?[0] ?? 'Unknown Artist',
      album: metadata.albumName ?? 'Unknown Album',
      duration: duration,
      url: path,
      artworkUrl: metadata.albumArt == null
          ? ''
          : await _saveArtwork(metadata.albumArt!, path),
      isFavorite: false,
      playlists: [],
    );
  }

  Future<String> _saveArtwork(Uint8List artwork, String audioPath) async {
    final appDir = await appDocumentsDir;
    // Generate a unique filename for the artwork
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final audioBaseName = audioPath.split('/').last.split('.').first;
    final fileName = '${audioBaseName}_artwork_$timestamp.jpg';
    final file = File('$appDir/$fileName');
    await file.writeAsBytes(artwork);

    log('Saved artwork to: ${file.path}');

    return file.path;
  }

  // CRUD Operations
  Future<int> saveTo(SongFile model) async {
    final db = await database;
    final result = await db.insert(
      _tableName,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _notifyChanges();

    return result;
  }

  Future<int> releaseTo(SongFile model) async {
    final db = await database;
    final result = await db.update(
      _tableName,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
    log('Updated $result rows for song ${model.id}');
    await _notifyChanges();

    return result;
  }

  Future<int> removeFrom(String id) async {
    final db = await database;
    final song = await getSongById(id);
    if (song != null) {
      if (song.url.isNotEmpty) {
        final file = File(song.url);
        if (await file.exists()) {
          await file.delete();
          log('Deleted audio file: ${song.url}');
        }
      }
      if (song.artworkUrl.isNotEmpty) {
        final file = File(song.artworkUrl);
        if (await file.exists()) {
          await file.delete();
          log('Deleted artwork file: ${song.artworkUrl}');
        }
      }
    }
    final result = await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    await _notifyChanges();

    return result;
  }

  Future<void> toggleFavorite(String id) async {
    final song = await getSongById(id);
    if (song != null) {
      await releaseTo(song.copyWith(isFavorite: !song.isFavorite));
    }
  }

  Future<String> addToPlaylist({
    required String id,
    required String name,
    VoidCallback? reload,
  }) async {
    final song = await getSongById(id);
    String playlist = '';
    if (song != null && !song.playlists.contains(name)) {
      song.playlists.add(name);
      await releaseTo(song);
    } else {
      for (var plst in song!.playlists) {
        if (plst == name) {
          playlist = plst;
        }
      }
    }

    reload?.call();

    return playlist;
  }

  Future<void> removeFromPlaylist({
    required String id,
    required String name,
    VoidCallback? reload,
  }) async {
    final song = await getSongById(id);
    if (song != null) {
      song.playlists.remove(name);
      await releaseTo(song);
    }

    reload?.call();
  }

  Future<SongFile?> getSongById(String id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) return SongFile.fromMap(maps.first);
    return null;
  }

  Future<List<SongFile>> _getAllSongs() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'title');
    return maps.map((map) => SongFile.fromMap(map)).toList();
  }

  Stream<List<SongFile>> get songsStream => _songsController.stream;

  StreamBuilder<List<SongFile>> songsStreamBuilder({
    required Widget Function(BuildContext context, List<SongFile> data) builder,
  }) {
    return StreamBuilder<List<SongFile>>(
      stream: songsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final songs = snapshot.data ?? [];
        if (songs.isEmpty) {
          return const Center(child: Text('No audio files found'));
        } else {
          return builder(context, songs);
        }
      },
    );
  }
}
