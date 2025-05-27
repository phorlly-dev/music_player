import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/sql/song_view.dart';
import 'package:music_player/core/services/song_service.dart';

class MyPlaylist extends StatefulWidget {
  const MyPlaylist({super.key});

  @override
  State<MyPlaylist> createState() => _MyPlaylistState();
}

class _MyPlaylistState extends State<MyPlaylist> {
  final service = Get.put(SongService());

  @override
  void initState() {
    super.initState();
    service.fetchSongFilesFromDevice();
  }

  @override
  Widget build(BuildContext context) {
    return service.songsStreamBuilder(
      builder: (context, songs) {
        return SongView.playListGrouped(context, songs);
      },
    );
  }
}
