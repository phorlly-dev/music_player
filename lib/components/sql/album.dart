import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/sql/song_view.dart';
import 'package:music_player/core/services/song_service.dart';

class MyAlbum extends StatefulWidget {
  const MyAlbum({super.key});

  @override
  State<MyAlbum> createState() => _MyAlbumState();
}

class _MyAlbumState extends State<MyAlbum> {
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
        return SongView.albumGrouped(context, songs);
      },
    );
  }
}
