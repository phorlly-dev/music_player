import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:music_player/core/models/audio_file.dart';
import 'package:music_player/core/services/audio_file_service.dart';
// import 'package:music_player/components/audio_form.dart';
import 'package:music_player/components/topbar.dart';

class SongPlayer extends StatefulWidget {
  final AudioFile audioFile;

  const SongPlayer({super.key, required this.audioFile});

  @override
  State<SongPlayer> createState() => _SongPlayerState();
}

class _SongPlayerState extends State<SongPlayer> {
  final AudioPlayer _player = AudioPlayer();
  final service = AudioFileService();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _player.setAudioSource(AudioSource.asset(widget.audioFile.url));
      // await _player.setUrl(widget.audioFile.url);
      log("Playing ${widget.audioFile.title} by ${widget.audioFile.artist}");
    } catch (e) {
      log("Error loading audio source: $e");
    }
  }

  Stream<DurationState> get durationStateStream =>
      Rx.combineLatest2<Duration, Duration, DurationState>(
        _player.positionStream,
        _player.durationStream.whereType<Duration>(),
        (position, duration) => DurationState(position, duration),
      );

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Topbar(
        title: "Music Player",
        content: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.audioFile.artworkUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image(
                        width: 500,
                        height: 250,
                        fit: BoxFit.cover,
                        image: AssetImage(widget.audioFile.artworkUrl),
                      ),
                    )
                  : Icon(Icons.music_note, size: 100),
              const SizedBox(height: 20),
              Text(
                widget.audioFile.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.audioFile.artist,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              StreamBuilder<DurationState>(
                stream: durationStateStream,
                builder: (context, snapshot) {
                  final durationState = snapshot.data;
                  final position = durationState?.position ?? Duration.zero;
                  final total = durationState?.total ?? Duration.zero;

                  return Column(
                    children: [
                      Slider(
                        min: 0.0,
                        max: total.inMilliseconds.toDouble(),
                        value: position.inMilliseconds.toDouble().clamp(
                          0.0,
                          total.inMilliseconds.toDouble(),
                        ),
                        onChanged: (value) {
                          _player.seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                      Text(
                        "${formatDuration(position)} / ${formatDuration(total)}",
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // Implement "Add New" functionality (e.g., upload song)
                      // AudioForm.showForm(context, null);
                    },
                    tooltip: "Add New",
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      // Implement "Add to Favorite" functionality
                    },
                    tooltip: "Add to Favorite",
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Implement "Add More" functionality (e.g., add to playlist)
                    },
                    tooltip: "Add More",
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _player.play(),
                    iconSize: 40,
                  ),
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () => _player.pause(),
                    iconSize: 40,
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: () => _player.stop(),
                    iconSize: 40,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(8, "0");
  }
}

class DurationState {
  final Duration position;
  final Duration total;

  DurationState(this.position, this.total);
}
