import 'package:flutter/material.dart';
import 'package:music_player/core/services/music_service.dart';

class MySong extends StatelessWidget {
  const MySong({super.key});

  @override
  Widget build(BuildContext context) {
    return MusicService().stream(context);
  }
}
