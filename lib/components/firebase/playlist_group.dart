import 'package:flutter/material.dart';
import 'package:music_player/core/services/music_service.dart';

class PlayListGroup extends StatelessWidget {
  const PlayListGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return MusicService().playListStream(context);
  }
}
