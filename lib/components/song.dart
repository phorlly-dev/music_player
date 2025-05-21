import 'package:flutter/material.dart';
import 'package:music_player/core/services/music_service.dart';
// import 'package:music_player/components/audio_view.dart';

class MySong extends StatelessWidget {
  const MySong({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // child: AudioView.audioFileListView(context, AudioView.mySongs),
      child: MusicService().stream(context),
    );
  }
}
