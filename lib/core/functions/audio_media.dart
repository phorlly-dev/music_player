import 'package:music_player/core/models/audio_file.dart';

class AudioMedia {
  static Map<String, List<AudioFile>> groupByAlbum(List<AudioFile> songs) {
    final Map<String, List<AudioFile>> grouped = {};
    for (var song in songs) {
      if (!grouped.containsKey(song.album)) {
        grouped[song.album] = [];
      }
      grouped[song.album]!.add(song);
    }
    return grouped;
  }

  static Map<String, List<AudioFile>> groupByPlayList(List<AudioFile> songs) {
    final Map<String, List<AudioFile>> grouped = {};
    for (var song in songs) {
      if (!grouped.containsKey(song.artist)) {
        grouped[song.artist] = [];
      }
      grouped[song.artist]!.add(song);
    }

    return grouped;
  }

  static Map<String, List<AudioFile>> groupByFavorite(List<AudioFile> songs) {
    final Map<String, List<AudioFile>> grouped = {};

    for (var song in songs) {
      if (song.isFavorite) {
        const key = 'favorite';

        // Initialize the list if the key doesn't exist
        if (!grouped.containsKey(key)) {
          grouped[key] = [];
        }

        // Add the song to the favorites list
        grouped[key]!.add(song);
      }
    }

    return grouped;
  }
}
