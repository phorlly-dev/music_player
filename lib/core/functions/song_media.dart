import 'package:music_player/core/models/song_file.dart';

class SongMedia {
  static Map<String, List<SongFile>> groupByAlbum(List<SongFile> songs) {
    final Map<String, List<SongFile>> grouped = {};
    for (var song in songs) {
      if (!grouped.containsKey(song.album)) {
        grouped[song.album] = [];
      }
      grouped[song.album]!.add(song);
    }
    return grouped;
  }

  static Map<String, List<SongFile>> groupByPlayList(List<SongFile> songs) {
    final Map<String, List<SongFile>> grouped = {};

    for (var song in songs) {
      // Only include songs where playlists is not null and not empty
      if (song.playlists != [] && song.playlists.isNotEmpty) {
        for (var playlist in song.playlists) {
          if (!grouped.containsKey(playlist)) {
            grouped[playlist] = [];
          }

          grouped[playlist]!.add(song);
        }
      }
    }

    return grouped;
  }

  static Map<String, List<SongFile>> groupByFavorite(List<SongFile> songs) {
    final Map<String, List<SongFile>> grouped = {};

    for (var song in songs) {
      if (song.isFavorite) {
        const key = '1';

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
