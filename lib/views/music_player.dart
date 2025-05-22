import 'package:flutter/material.dart';
import 'package:music_player/components/audio_form.dart';
import 'package:music_player/components/favorite_group.dart';
import 'package:music_player/components/index.dart';
import 'package:music_player/core/services/music_service.dart';
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
  final service = MusicService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Tabbar(
        title: 'Music Player UI',
        tabs: const [
          Tab(text: 'Songs'),
          Tab(text: 'Favorites'),
          Tab(text: 'Playlists'),
          Tab(text: 'Albums'),
        ],
        tabViews: const [MySong(), MyFavorite(), MyPlayList(), MyAlbum()],
        button: Controls.icon(
          pressed: () => AudioForm.showForm(context, null),
          icon: Icons.add,
          width: 40,
        ),
      ),
    );
  }
}
