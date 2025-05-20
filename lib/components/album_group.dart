import 'package:flutter/material.dart';
import 'package:music_player/components/audio_view.dart';

class MyAlbum extends StatelessWidget {
  const MyAlbum({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20, left: 12, right: 12),
      child: Expanded(
        child: AudioView.albumGroupedListView(context, AudioView.mySongs),
      ),
    );
  }
}
