import 'package:flutter/material.dart';
import 'package:music_player/core/services/audio_file_service.dart';
import 'package:music_player/components/tabbar.dart';
import 'package:music_player/components/album_group.dart';
import 'package:music_player/components/playlist_group.dart';
import 'package:music_player/components/song.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final service = AudioFileService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Tabbar(
        title: 'Music Player UI',
        tabs: const [
          Tab(text: 'Songs'),
          Tab(text: 'Playlists'),
          Tab(text: 'Albums'),
        ],
        tabViews: const [
          Center(child: MySong()),
          Center(child: MyPlayList()),
          Center(child: MyAlbum()),
        ],
      ),
    );
  }
}
