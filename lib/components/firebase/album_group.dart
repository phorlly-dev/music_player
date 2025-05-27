import 'package:flutter/material.dart';
import 'package:music_player/core/services/music_service.dart';

class AlbumGroup extends StatelessWidget {
  const AlbumGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return MusicService().albumStream(context);
  }
}
