import 'package:flutter/material.dart';
import 'package:music_player/core/models/audio_file.dart';
import 'package:music_player/core/functions/audio_media.dart';
import 'package:music_player/core/links/nav_link.dart';
import 'package:music_player/components/sample.dart';
import 'package:music_player/components/song_player.dart';

class AudioView {
  static Widget audioFileListView(
    BuildContext context,
    List<AudioFile> audioFiles,
  ) {
    return ListView.builder(
      itemCount: audioFiles.length,
      itemBuilder: (context, index) {
        final item = audioFiles[index];

        return Card(
          child: ListTile(
            leading: ImageAsset(path: item.artworkUrl),
            title: Text(item.title),
            subtitle: Text('${item.artist} • ${item.album}'),
            trailing: Icon(
              item.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: item.isFavorite ? Colors.red : null,
            ),
            onTap: () {
              NavLink.go(
                context: context,
                screen: SongPlayer(audioFile: item),
              );
              // log("Tapped on ${item.title}");
            },
          ),
        );
      },
    );
  }

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
            Divider(
              thickness: 2, // Line thickness
              indent: 10, // Left padding
              endIndent: 10, // Right padding
            ),
            ...albumSongs.map((song) => imageCard(context, model: song)),
          ],
        );
      }).toList(),
    );
  }

  static Widget playListGrouped(BuildContext context, List<AudioFile> songs) {
    final groupedSongs = AudioMedia.groupByPlayList(songs);

    return ListView(
      children: groupedSongs.entries.map((entry) {
        final albumName = entry.key;
        final albumSongs = entry.value;

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
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
              Divider(
                thickness: 2, // Line thickness
                indent: 10, // Left padding
                endIndent: 10, // Right padding
              ),
              ...albumSongs.map((song) => imageCard(context, model: song)),
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
        final albumSongs = entry.value;

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...albumSongs.map((song) => imageCard(context, model: song)),
            ],
          ),
        );
      }).toList(),
    );
  }

  static Widget imageCard(BuildContext context, {required AudioFile model}) {
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
              screen: SongPlayer(audioFile: model),
            );
          },
        ),
      ),
    );
  }

  static final List<AudioFile> mySongs = [
    AudioFile(
      id: '1',
      title: 'Yung Kai Blue',
      artist: 'Official MV',
      album: 'Vol 1',
      duration: Duration(minutes: 4, seconds: 12),
      url: 'assets/audios/1.mp3',
      artworkUrl: 'assets/images/1.png',
      isFavorite: true,
    ),
    AudioFile(
      id: '2',
      title: 'Night Changes',
      artist: ' ',
      album: 'Vol 1',
      duration: Duration(minutes: 3, seconds: 45),
      url: 'assets/audios/2.mp3',
      artworkUrl: 'assets/images/2.png',
      isFavorite: false,
    ),
    AudioFile(
      id: '3',
      title: 'Ed Sheeran  Perfect',
      artist: 'Lyric',
      album: 'Vol 2',
      duration: Duration(minutes: 4, seconds: 12),
      url: 'assets/audios/3.mp3',
      artworkUrl: 'assets/images/3.png',
      isFavorite: false,
    ),
    AudioFile(
      id: '4',
      title: 'Yellow',
      artist: 'Coldplay',
      album: 'Vol 2',
      duration: Duration(minutes: 4, seconds: 12),
      url: 'assets/audios/4.mp3',
      artworkUrl: 'assets/images/4.png',
      isFavorite: false,
    ),
    AudioFile(
      id: '5',
      title: 'The Scientis',
      artist: 'Coldplay',
      album: 'Vol 1',
      duration: Duration(minutes: 4, seconds: 12),
      url: 'assets/audios/5.mp3',
      artworkUrl: 'assets/images/5.png',
      isFavorite: false,
    ),
    AudioFile(
      id: '6',
      title: 'Numb',
      artist: 'Linkin Park',
      album: 'Vol 2',
      duration: Duration(minutes: 4, seconds: 12),
      url: 'assets/audios/6.mp3',
      artworkUrl: 'assets/images/6.png',
      isFavorite: false,
    ),
    AudioFile(
      id: '7',
      title: 'Counting Stars',
      artist: 'OneRepublic',
      album: 'vol 2',
      duration: Duration(minutes: 4, seconds: 12),
      url: 'assets/audios/7.mp3',
      artworkUrl: 'assets/images/7.png',
      isFavorite: false,
    ),
    AudioFile(
      id: '8',
      title: 'Here Without You',
      artist: '3 Doors Down',
      album: 'Vol 1',
      duration: Duration(minutes: 4, seconds: 12),
      url: 'assets/audios/8.mp3',
      artworkUrl: 'assets/images/8.png',
      isFavorite: true,
    ),
    AudioFile(
      id: '9',
      title: 'We Will Rock You',
      artist: 'Queen',
      album: 'Vol 3',
      duration: Duration(minutes: 4, seconds: 12),
      url: 'assets/audios/9.mp3',
      artworkUrl: 'assets/images/9.png',
      isFavorite: false,
    ),
    AudioFile(
      id: '10',
      title: 'Alone',
      artist: 'Marshmello',
      album: 'Vol 2',
      duration: Duration(minutes: 4, seconds: 12),
      url: 'assets/audios/10.mp3',
      artworkUrl: 'assets/images/10.png',
      isFavorite: false,
    ),
    AudioFile(
      id: '11',
      title: 'The Lazy Song',
      artist: 'Bruno Mars',
      album: 'Vol 2',
      duration: Duration(minutes: 4, seconds: 12),
      url: 'assets/audios/11.mp3',
      artworkUrl: 'assets/images/11.png',
      isFavorite: false,
    ),
    AudioFile(
      id: '12',
      title: 'Maroon 5 - Girls Like You ft. Cardi B',
      artist: 'Maroon 5',
      album: 'Vol 1',
      duration: Duration(minutes: 4, seconds: 12),
      url: 'assets/audios/12.mp3',
      artworkUrl: 'assets/images/12.png',
      isFavorite: false,
    ),
    AudioFile(
      id: '13',
      title: 'Shape of You',
      artist: 'Ed Sheeran',
      album: 'Vol 3',
      duration: Duration(minutes: 4, seconds: 12),
      url: 'assets/audios/13.mp3',
      artworkUrl: 'assets/images/13.png',
      isFavorite: false,
    ),
  ];
}
