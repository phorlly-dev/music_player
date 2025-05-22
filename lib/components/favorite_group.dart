import 'package:flutter/material.dart';
import 'package:music_player/core/services/music_service.dart';

class MyFavorite extends StatelessWidget {
  const MyFavorite({super.key});

  @override
  Widget build(BuildContext context) {
    return MusicService().favoriteStream(context);
  }
}
