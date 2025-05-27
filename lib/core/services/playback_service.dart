import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/core/models/song_file.dart';

class PlaybackService {
  static final PlaybackService _instance = PlaybackService._internal();
  factory PlaybackService() => _instance;
  PlaybackService._internal();

  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> init(List<SongFile> songs, int initialIndex) async {
    final songList = ConcatenatingAudioSource(
      children: songs.asMap().entries.map((entry) {
        // final index = entry.key;
        final song = entry.value;

        return AudioSource.uri(
          Uri.file(song.url),
          tag: MediaItem(
            id: song.id,
            title: song.title,
            artist: song.artist,
            album: song.album,
            duration: song.duration,
            artUri: song.artworkUrl.isNotEmpty
                ? Uri.file(song.artworkUrl)
                : null,
          ),
        );
      }).toList(),
    );

    await _player.setAudioSource(songList, initialIndex: initialIndex);
  }

  Future<void> play() async => await _player.play();
  Future<void> pause() async => await _player.pause();
  Future<void> seek(Duration position) async => await _player.seek(position);
  Future<void> next() async => await _player.seekToNext();
  Future<void> previous() async => await _player.seekToPrevious();

  void dispose() {
    _player.dispose();
  }
}
