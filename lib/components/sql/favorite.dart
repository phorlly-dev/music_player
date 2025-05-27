import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/sql/song_view.dart';
import 'package:music_player/core/services/song_service.dart';

class MyFavorite extends StatefulWidget {
  const MyFavorite({super.key});

  @override
  State<MyFavorite> createState() => _MyFavoriteState();
}

class _MyFavoriteState extends State<MyFavorite> {
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
        return SongView.favoriteGrouped(context, songs);
      },
    );
  }
}
