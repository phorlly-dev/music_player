import 'package:flutter/material.dart';
import 'package:music_player/core/services/music_service.dart';
// import 'package:music_player/components/audio_view.dart';

class MyFavorite extends StatelessWidget {
  const MyFavorite({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // child: AudioView.playListGroupedListView(context, AudioView.mySongs),
      child: MusicService().favoriteStream(context),
    );
  }
}
