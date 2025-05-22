import 'package:flutter/material.dart';
import 'package:music_player/components/audio_view.dart';
import 'package:music_player/core/models/audio_file.dart';
import 'package:music_player/core/services/service.dart';

class MusicService extends Service {
  Future<List<AudioFile>> index() {
    return geter(
      collection: 'musics',
      fromMap: (data, id) => AudioFile.fromMap(data, id),
    );
  }

  // Add a new
  Future<void> store(AudioFile object) async {
    await poster<AudioFile>(
      model: object,
      collection: 'musics',
      toMap: (value) => value.toMap(),
    );
  }

  // Update an existing AudioFile
  Future<void> update(AudioFile object) async {
    // Update the AudioFile in Firestore
    await puter(collection: 'musics', docId: object.id, toMap: object.toMap());
  }

  // Delete an AudioFile by its ID
  Future<void> remove(String id) async {
    await deleter(collection: 'musics', docId: id);
  }

  // Stream builder for reusable widget
  Widget stream(BuildContext context) {
    return streamBuilder<AudioFile>(
      collection: 'musics',
      fromMap: (data, docId) => AudioFile.fromMap(data, docId),
      builder: (context, data) {
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            // log('The item: ${item.title} by ${item.artist}');

            return AudioView.imageCard(
              context,
              model: item,
              index: index,
              playlist: data,
              title: 'Songs',
            );
            // return ListTile(
            //   leading: ImageAssetAvatr(path: item.artworkUrl),
            //   title: Text(item.title),
            //   subtitle: Text('${item.artist} • ${item.album}'),
            //   trailing: Icon(
            //     item.isFavorite ? Icons.favorite : Icons.favorite_border,
            //     color: item.isFavorite ? Colors.red : null,
            //   ),
            //   onTap: () {
            //     NavLink.go(
            //       context: context,
            //       screen: SongPlayer(audioFile: item),
            //     );
            //     log("Tapped on ${item.title}");
            //   },
            // );
          },
        );
      },
    );
  }

  // Stream builder for reusable widget
  Widget playListStream(BuildContext context) {
    return streamBuilder<AudioFile>(
      collection: 'musics',
      fromMap: (data, docId) => AudioFile.fromMap(data, docId),
      builder: (context, data) {
        return AudioView.playListGrouped(context, data);
      },
    );
  }

  // Stream builder for reusable widget
  Widget albumStream(BuildContext context) {
    return streamBuilder<AudioFile>(
      collection: 'musics',
      fromMap: (data, docId) => AudioFile.fromMap(data, docId),
      builder: (context, data) {
        return AudioView.albumGrouped(context, data);
      },
    );
  }

  // Stream builder for reusable widget
  Widget favoriteStream(BuildContext context) {
    return streamBuilder<AudioFile>(
      collection: 'musics',
      fromMap: (data, docId) => AudioFile.fromMap(data, docId),
      builder: (context, data) {
        return AudioView.favoriteGrouped(context, data);
      },
    );
  }
}
