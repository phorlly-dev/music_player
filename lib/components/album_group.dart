import 'package:flutter/material.dart';
import 'package:music_player/core/services/music_service.dart';
// import 'package:music_player/components/audio_view.dart';

class MyAlbum extends StatelessWidget {
  const MyAlbum({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // child: AudioView.albumGroupedListView(context, AudioView.mySongs),
      child: MusicService().albumStream(context),
    );
  }
}
