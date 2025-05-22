import 'package:flutter/material.dart';
import 'package:music_player/core/services/music_service.dart';

class MyPlayList extends StatelessWidget {
  const MyPlayList({super.key});

  @override
  Widget build(BuildContext context) {
    return MusicService().playListStream(context);
  }
}
