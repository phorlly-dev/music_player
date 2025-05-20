import 'package:flutter/material.dart';
import 'package:music_player/core/models/audio_file.dart';

class SongTile extends StatelessWidget {
  final AudioFile song;

  const SongTile({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: song.artworkUrl.isNotEmpty
          ? Image.network(
              song.artworkUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.music_note),
            )
          : const Icon(Icons.music_note),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: song.isFavorite
          ? const Icon(Icons.favorite, color: Colors.red)
          : null,
      onTap: () {
        // Play song or navigate to detail page
      },
    );
  }
}
