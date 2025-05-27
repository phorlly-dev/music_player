import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/core/controllers/player_controller.dart';
import 'package:music_player/core/functions/song_media.dart';
import 'package:music_player/core/models/song_file.dart'; // Adjust import as needed
import 'package:music_player/components/global/sample.dart'; // For ImageAsset, NavLink, SongPlayer

class SongView {
  // Assume groupByAlbum, groupByPlayList, groupByFavorite are defined elsewhere
  static Widget albumGrouped(BuildContext context, List<SongFile> songs) {
    final groupedSongs = SongMedia.groupByAlbum(songs);

    return ListView(
      children: groupedSongs.entries.map((entry) {
        final albumName = entry.key;
        final albumSongs = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 14, left: 12),
              child: Text(
                albumName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(thickness: 2, indent: 10, endIndent: 10),
            ...albumSongs.map((song) {
              return imageCard(
                context,
                model: song,
                index: albumSongs.indexOf(song),
                songList: albumSongs,
                title: 'Album',
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  static Widget playListGrouped(BuildContext context, List<SongFile> songs) {
    final groupedSongs = SongMedia.groupByPlayList(songs);

    // If no playlists are available, show a message
    if (groupedSongs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No playlists available!',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView(
      children: groupedSongs.entries.map((entry) {
        final playlistName = entry.key;
        final playlistSongs = entry.value;
        // log('Playlist: $playlistName, Songs: ${playlistSongs.length}');

        // Explicitly exclude null playlistName (defensive check)
        if (playlistName == '') {
          return SizedBox.shrink(); // Skip this entry silently
        }

        // Since groupByPlayList ensures playlistName is not null or empty and has songs,
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 12),
                child: Text(
                  playlistName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(thickness: 2, indent: 10, endIndent: 10),
              ...playlistSongs.map((song) {
                return imageCard(
                  context,
                  model: song,
                  index: playlistSongs.indexOf(song),
                  songList: playlistSongs,
                  title: 'Playlist',
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  static Widget favoriteGrouped(BuildContext context, List<SongFile> songs) {
    final groupedSongs = SongMedia.groupByFavorite(songs);

    return ListView(
      children: groupedSongs.entries.map((entry) {
        final favoriteSongs = entry.value;

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...favoriteSongs.map((song) {
                return imageCard(
                  context,
                  model: song,
                  index: favoriteSongs.indexOf(song),
                  songList: favoriteSongs,
                  title: 'Favorites',
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  static Widget imageCard(
    BuildContext context, {
    required SongFile model,
    required List<SongFile> songList,
    required int index,
    required String title,
  }) {
    return Card(
      child: ListTile(
        leading: ImgAsset(path: model.artworkUrl),
        title: Text(model.title),
        subtitle: Text('${model.artist} • ${model.album}'),
        trailing: Icon(
          model.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: model.isFavorite ? Colors.red : null,
        ),
        onTap: () {
          final controller = Get.put(PlayerController());
          controller.init(songList, index);
          controller.title.value = title;
        },
      ),
    );
  }
}
