import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:music_player/core/links/nav_link.dart';
import 'package:music_player/core/models/audio_file.dart';
import 'package:music_player/core/services/service.dart';
import 'package:music_player/components/sample.dart';
import 'package:music_player/components/song_player.dart';

class AudioFileService {
  Future<List<AudioFile>> index() {
    return Service.readAll(
      collectionName: 'audioFiles',
      fromMap: (data, id) => AudioFile.fromMap(data, id),
    );
  }

  // Add a new
  static Future<void> store(AudioFile object) async {
    await Service.create<AudioFile>(
      model: object,
      collectionName: 'audioFiles',
      toMap: (value) => value.toMap(),
    );
  }

  // Update an existing AudioFile
  Future<void> update(AudioFile object) async {
    // Update the AudioFile in Firestore
    await Service.update(
      collectionName: 'audioFiles',
      docId: object.id,
      toMap: object.toMap(),
    );
  }

  // Delete an AudioFile by its ID
  Future<void> remove(String id) async {
    await Service.delete(collectionName: 'audioFiles', docId: id);
  }

  // Stream builder for reusable widget
  Widget stream(BuildContext context) {
    return Service.streamBuilder<AudioFile>(
      collectionName: 'audioFiles',
      fromMap: (data, docId) => AudioFile.fromMap(data, docId),
      builder: (context, data) {
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            log('The item: ${item.title} by ${item.artist}');

            return ListTile(
              leading: ImageAssetAvatr(path: item.artworkUrl),
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
                log("Tapped on ${item.title}");
              },
            );
          },
        );
      },
    );
  }
}
