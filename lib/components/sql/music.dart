import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/sql/song_view.dart';
import 'package:music_player/core/services/song_service.dart';

class MyMusic extends StatefulWidget {
  const MyMusic({super.key});

  @override
  State<MyMusic> createState() => _MyMusicState();
}

class _MyMusicState extends State<MyMusic> {
  final SongService service = Get.put(SongService());

  @override
  void initState() {
    super.initState();
    service.fetchSongFilesFromDevice();
  }

  @override
  Widget build(BuildContext context) {
    return service.songsStreamBuilder(
      builder: (context, songs) {
        return ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];

            return SongView.imageCard(
              context,
              index: index,
              model: song,
              songList: songs,
              title: 'Song',
            );
          },
        );
      },
    );
  }
}
