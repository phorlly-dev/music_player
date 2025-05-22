import 'package:flutter/material.dart';
import 'package:music_player/components/song_player.dart';
import 'package:music_player/core/functions/audio_media.dart';
import 'package:music_player/core/links/nav_link.dart';
import 'package:music_player/core/models/audio_file.dart'; // Adjust import as needed
import 'package:music_player/components/sample.dart'; // For ImageAsset, NavLink, SongPlayer

class AudioView {
  // Assume groupByAlbum, groupByPlayList, groupByFavorite are defined elsewhere

  static Widget albumGrouped(BuildContext context, List<AudioFile> songs) {
    final groupedSongs = AudioMedia.groupByAlbum(songs);

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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(thickness: 2, indent: 10, endIndent: 10),
            ...albumSongs.map((song) {
              int index = albumSongs.indexOf(song);

              return imageCard(
                context,
                model: song,
                index: index,
                playlist: albumSongs,
                title: 'Albums',
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  static Widget playListGrouped(BuildContext context, List<AudioFile> songs) {
    final groupedSongs = AudioMedia.groupByPlayList(songs);

    return ListView(
      children: groupedSongs.entries.map((entry) {
        final playlistName = entry.key;
        final playlistSongs = entry.value;

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 14, left: 12),
                child: Text(
                  playlistName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(thickness: 2, indent: 10, endIndent: 10),
              ...playlistSongs.map((song) {
                int index = playlistSongs.indexOf(song);

                return imageCard(
                  context,
                  model: song,
                  index: index,
                  playlist: playlistSongs,
                  title: 'Playlists',
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  static Widget favoriteGrouped(BuildContext context, List<AudioFile> songs) {
    final groupedSongs = AudioMedia.groupByFavorite(songs);

    return ListView(
      children: groupedSongs.entries.map((entry) {
        final favoriteSongs = entry.value;

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...favoriteSongs.map((song) {
                int index = favoriteSongs.indexOf(song);

                return imageCard(
                  context,
                  model: song,
                  index: index,
                  playlist: favoriteSongs,
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
    required AudioFile model,
    required List<AudioFile> playlist,
    required int index,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Card(
        child: ListTile(
          leading: ImageAsset(path: model.artworkUrl),
          title: Text(model.title),
          subtitle: Text('${model.artist} • ${model.album}'),
          trailing: Icon(
            model.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: model.isFavorite ? Colors.red : null,
          ),
          onTap: () {
            NavLink.go(
              context: context,
              screen: SongPlayer(
                playlist: playlist,
                initialIndex: index,
                title: title,
              ),
            );
          },
        ),
      ),
    );
  }
}
