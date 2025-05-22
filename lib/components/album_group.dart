import 'package:flutter/material.dart';
import 'package:music_player/core/services/music_service.dart';

class MyAlbum extends StatelessWidget {
  const MyAlbum({super.key});

  @override
  Widget build(BuildContext context) {
    return MusicService().albumStream(context);
  }
}
