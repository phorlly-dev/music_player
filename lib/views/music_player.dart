import 'package:flutter/material.dart';
import 'package:music_player/components/firebase/album_group.dart';
import 'package:music_player/components/firebase/favorite_group.dart';
import 'package:music_player/components/firebase/playlist_group.dart';
import 'package:music_player/components/firebase/song.dart';
import 'package:music_player/components/global/audio_form.dart';
import 'package:music_player/components/global/tabbar.dart';

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key});

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
        tabViews: const [
          MySong(),
          FavoriteGroup(),
          PlayListGroup(),
          AlbumGroup(),
        ],
        button: IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => AudioForm.showFormTo(context, null),
          tooltip: 'Add New Song',
          color: Colors.blue,
        ),
      ),
    );
  }
}
