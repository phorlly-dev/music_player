import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/components/global/audio_form.dart';
import 'package:music_player/components/global/tabbar.dart';
import 'package:music_player/components/sql/album.dart';
import 'package:music_player/components/sql/favorite.dart';
import 'package:music_player/components/sql/music.dart';
import 'package:music_player/components/sql/player.dart';
import 'package:music_player/components/sql/player_bottom_sheet.dart';
import 'package:music_player/components/sql/playlist.dart';
import 'package:music_player/core/controllers/player_controller.dart';
import 'package:music_player/core/services/song_service.dart';

class SongPlayer extends StatefulWidget {
  const SongPlayer({super.key});

  @override
  State<SongPlayer> createState() => _SongPlayerState();
}

class _SongPlayerState extends State<SongPlayer> {
  final player = Get.put(PlayerController());
  final service = Get.put(SongService());

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() {
    service.fetchSongFilesFromDevice();
  }

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
        tabViews: const [MyMusic(), MyFavorite(), MyPlaylist(), MyAlbum()],
        button: IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () =>
              AudioForm.showForm(context, model: null, reload: reload),
          tooltip: 'Add New Song',
          color: Colors.blue,
        ),
        bottom: Obx(() {
          if (player.songs.isEmpty) {
            return ListTile(
              title: const Text('No song playing', textAlign: TextAlign.center),
              contentPadding: const EdgeInsets.all(16.0),
              minVerticalPadding: 0,
            );
          }
          return PlayerBottomSheet(
            pushTo: () {
              Get.to(
                () => MyPlayer(
                  songList: player.songs,
                  initialIndex: player.currentIndex.value,
                  title: player.title.value,
                  refresh: reload,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
